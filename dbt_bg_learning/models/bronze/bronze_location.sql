{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='customer_id',
        schema = "bronze"
    )
}}

WITH source_location AS(
    SELECT
        _FILE_NAME AS loaded_from_file,
        current_timestamp() AS dbt_ingest_timestamp,
        TRIM(CID)AS customer_id,
        TRIM(CNTRY) AS country
    FROM 
        {{ source('gcs_landing', 'ext_location') }}
)
SELECT * FROM source_location