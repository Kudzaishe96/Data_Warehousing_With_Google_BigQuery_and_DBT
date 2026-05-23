{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='erp_products_id'
    )
}}

with silver_erp_products AS (
    SELECT
        erp_products_id,
        erp_products_catergory,
        erp_products_subcatergory,
        erp_products_maintenance,
        loaded_from_file AS source_file_name,
        dbt_ingest_timestamp AS bronze_ingest_timestamp,
        dbt_valid_from AS record_activated_at,
        dbt_valid_to,
        dbt_scd_id,
        dbt_updated_at
    FROM {{ ref('products_erp_snapshot') }}
    

)
SELECT * FROM silver_erp_products