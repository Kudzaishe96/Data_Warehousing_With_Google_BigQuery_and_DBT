{{
    config(
        materialized='table',
        schema='silver',
        description="Cleaned historical master log of customers. Contains all historical SCD Type 2 variations."
    )
}}

WITH cleaned_history AS (
    SELECT
        
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS customer_sk,
        -- 1. Core Business Keys
        customer_id,
        customer_key,
        
        -- 2. Transformed & Standardized Attributes
        TRIM(first_name) AS first_name,
        TRIM(last_name) AS last_name,
        
        CASE 
            WHEN UPPER(TRIM(marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS marital_status,
        
        CASE 
            WHEN UPPER(TRIM(gender)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(gender)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS gender,
        
        customer_create_date,

        -- 3. Historical Timeline Parameters (Essential for Analysts!)
        dbt_valid_from AS record_valid_from,
        dbt_valid_to AS record_valid_to,
        dbt_scd_id AS unique_version_key,
        
        -- 4. Ingestion Traceability
        loaded_from_file AS source_file_name,
        dbt_ingest_timestamp AS bronze_ingest_timestamp

    FROM {{ ref('customer_snapshot') }}
    WHERE customer_id IS NOT NULL
)

SELECT * FROM cleaned_history
ORDER BY customer_id, record_valid_from ASC