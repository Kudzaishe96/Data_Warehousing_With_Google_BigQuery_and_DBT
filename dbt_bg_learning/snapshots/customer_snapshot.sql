{% snapshot customer_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='customer_id',
      strategy='check',
      check_cols=['first_name','last_name','marital_status','gender']
    )
}}
WITH ranked_customers AS (
    SELECT
        customer_id,
        customer_key,
        first_name,
        last_name,
        marital_status,
        gender,
        customer_create_date,
        loaded_from_file,
        dbt_ingest_timestamp,
        -- Generate a rank where 1 is the absolute newest state of the customer record
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY dbt_ingest_timestamp DESC
        ) AS row_num
    FROM {{ ref('bronze_customer') }}
)

SELECT
    customer_id,
    customer_key,
    first_name,
    last_name,
    marital_status,
    gender,
    customer_create_date,
    loaded_from_file,
    dbt_ingest_timestamp
FROM ranked_customers
WHERE row_num = 1



{% endsnapshot %}