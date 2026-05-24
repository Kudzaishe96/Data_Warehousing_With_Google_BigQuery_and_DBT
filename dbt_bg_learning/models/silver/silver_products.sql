{{
  config(
    materialized='incremental',
    unique_key='product_id',
    incremental_strategy='merge',
    schema='silver'
  )
}}


With transformed_products_snapshot AS(
    SELECT
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_sk,
        product_id,
        REPLACE(SUBSTR(product_key, 1, 5), '-', '_') AS catergory_id,
        SUBSTR(product_key, 7, LENGTH(product_key)) AS product_key,
        product_number,
        SPLIT(product_number, '-')[0] AS product_name,
        SPLIT(product_number, '-')[0] AS product_colour,
        COALESCE(product_cost, 0) AS product_cost,
        CASE 
				WHEN UPPER(TRIM(product_line)) = 'M' THEN 'Mountain'
				WHEN UPPER(TRIM(product_line)) = 'R' THEN 'Road'
				WHEN UPPER(TRIM(product_line)) = 'S' THEN 'Other Sales'
				WHEN UPPER(TRIM(product_line)) = 'T' THEN 'Touring'
				ELSE 'n/a'
		END AS product_line,
        CAST(product_start_date AS DATE) AS product_start_date,
        CAST(product_end_date AS DATE) AS product_end_date,

        loaded_from_file AS source_file_name,
        dbt_ingest_timestamp AS bronze_ingest_timestamp,
        dbt_valid_from AS record_activated_at,
        dbt_scd_id,
        -- Pulling system tracking field to power the incremental filter
        dbt_updated_at 

    FROM {{ ref('products_snapshot') }}
    WHERE dbt_valid_to IS NULL
      AND product_id IS NOT NULL
    
    
)
SELECT 
    product_sk,
    product_id,
    product_key,
    product_number,
    product_name,
    product_colour,
    product_cost,
    product_line,
    catergory_id,
    product_start_date,
    product_end_date,
    source_file_name,
    bronze_ingest_timestamp,
    record_activated_at,
    dbt_scd_id
FROM transformed_products_snapshot 
ORDER BY product_start_date,product_id ASC