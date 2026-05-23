{{
    config(
        materialized='incremental',
        incremental_strategy='insert_overwrite',
        partition_by={
            "field": "dbt_ingest_timestamp",
            "data_type": "timestamp",
            "granularity": "day"
        },
        cluster_by=["sales_order_number", "sales_customer_id"],
        schema='silver'
    )
}}

WITH raw_source AS (
    SELECT 
        -- Bring through the original audit columns from Bronze
        loaded_from_file,
        dbt_ingest_timestamp,
        
        -- Core Keys
        sales_order_number,
        sales_product_number,
        sales_customer_id,
        
        -- Dates
        sales_order_date,
        sales_ship_date,
        sales_due_date,
        
        -- Quantities and amounts
        sales_quantity,
        sales,
        sales_price
    FROM {{ ref('bronze_sales') }}

    {% if is_incremental() %}
      -- --- FIXED THE PARTITION OVERWRITE BUG ---
      -- By filtering on the existing dbt_ingest_timestamp from Bronze, 
      -- BigQuery only reads and overwrites the exact daily partitions touched in the last 30 days.
      WHERE dbt_ingest_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
    {% endif %}
),

cleaned_calculations AS (
    SELECT
        loaded_from_file,
        dbt_ingest_timestamp,
        sales_order_number,
        sales_product_number,
        sales_customer_id,
        sales_order_date,
        sales_ship_date,
        sales_due_date,
        sales_quantity,

        -- 1. Clean up price boundaries first to avoid calculation conflicts
        CASE 
            WHEN sales_price IS NULL OR sales_price <= 0 THEN NULL
            ELSE ABS(sales_price)
        END AS clean_price,

        -- 2. Clean up sales boundaries
        CASE 
            WHEN sales IS NULL OR sales <= 0 THEN NULL
            ELSE sales
        END AS clean_sales

    FROM raw_source
),

final_transformations AS (
    SELECT
        loaded_from_file,
        dbt_ingest_timestamp,
        sales_order_number,
        sales_product_number,
        sales_customer_id,
        sales_order_date,
        sales_ship_date,
        sales_due_date,
        sales_quantity,

        -- If the price was broken, back-calculate it safely using clean sales data
        COALESCE(
            clean_price, 
            SAFE_DIVIDE(clean_sales, NULLIF(sales_quantity, 0))
        ) AS sales_price,

        -- If sales total was broken, recalculate it cleanly using clean price data
        COALESCE(
            clean_sales,
            sales_quantity * COALESCE(clean_price, 0)
        ) AS sales

    FROM cleaned_calculations
)

SELECT * FROM final_transformations