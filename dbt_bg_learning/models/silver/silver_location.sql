{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='customer_id'
    )
}}

with silver_location AS (
    SELECT
        REPLACE(customer_id, '-', '') AS customer_id, 
		CASE
		  WHEN TRIM(country) = 'DE' THEN 'Germany'
		  WHEN TRIM(country) IN ('US', 'USA') THEN 'United States'
		  WHEN TRIM(country) = '' OR country IS NULL THEN 'n/a'
		  ELSE TRIM(country) 
        END AS country,
        loaded_from_file,
        dbt_ingest_timestamp,
        dbt_valid_from AS record_activated_at,
        dbt_scd_id,
        -- Pulling system tracking field to power the incremental filter
        dbt_updated_at 
    FROM {{ ref('location_snapshot') }}
    WHERE dbt_valid_to IS NULL

)
SELECT * FROM silver_location