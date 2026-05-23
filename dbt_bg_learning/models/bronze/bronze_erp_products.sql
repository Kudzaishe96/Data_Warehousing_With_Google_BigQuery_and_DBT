{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='erp_products_id'
    )
}}

WITH source_erp_products AS(
    SELECT
        _FILE_NAME AS loaded_from_file,
        current_timestamp() AS dbt_ingest_timestamp,
        TRIM(ID) AS erp_products_id,
        TRIM(CAT) AS erp_products_catergory,
        TRIM(SUBCAT) AS erp_products_subcatergory,
        TRIM(MAINTENANCE) AS erp_products_maintenance
    FROM
    {{ source('gcs_landing', 'ext_erp_products') }}
)
SELECT * FROM source_erp_products
