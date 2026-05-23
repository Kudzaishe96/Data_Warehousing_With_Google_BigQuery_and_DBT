{{
    config(
        materialized='incremental',
        unique_key='customer_id',
        incremental_strategy='merge',
        schema='silver'
    )
}}

WITH transformed_snapshot AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS customer_sk,
        customer_id,
        customer_key,
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
        loaded_from_file AS source_file_name,
        dbt_ingest_timestamp AS bronze_ingest_timestamp,
        dbt_valid_from AS record_activated_at,
        dbt_scd_id,
        -- Pulling system tracking field to power the incremental filter
        dbt_updated_at 

    FROM {{ ref('customer_snapshot') }}
    WHERE dbt_valid_to IS NULL
      AND customer_id IS NOT NULL

    {% if is_incremental() %}
      -- Only process records that the snapshot engine touched since the last Silver run
      AND dbt_updated_at > (SELECT MAX(record_activated_at) FROM {{ this }})
    {% endif %}
)

SELECT
    customer_sk,
    customer_id,
    customer_key,
    first_name,
    last_name,
    marital_status,
    gender,
    customer_create_date,
    source_file_name,
    bronze_ingest_timestamp,
    record_activated_at,
    dbt_scd_id
FROM transformed_snapshot
ORDER BY customer_create_date, customer_id ASC