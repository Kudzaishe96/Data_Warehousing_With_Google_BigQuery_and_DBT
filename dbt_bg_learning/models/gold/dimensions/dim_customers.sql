--Gold dimensions are best built as full tables for BI performance
{{
    config(
        materialized='table',  
        schema='gold'
    )
}}

with silver_customer as (
    select * from {{ ref('silver_customer') }} -- References your clean silver table
),

silver_location AS(
    SELECT * FROM {{ ref('silver_location') }}
),

final_dimension as (
    select
        -- 1. Generate a clean Surrogate Key for the Gold Dimension
        {{ dbt_utils.generate_surrogate_key(['c.customer_id']) }} as customer_sk,
        
        -- 2. Business Keys & Natural Attributes
        c.customer_id,
        c.customer_key,
        c.first_name,
        c.last_name,
        -- Creating a useful concatenated field for easy searching in Power BI
        concat(c.first_name, ' ', c.last_name) as full_name,
        
        c.marital_status,
        c.gender,
        d.country,
        c.customer_create_date,
        
        -- 3. Audit Metadata preserved for backend support...
        d.loaded_from_file,
        c.source_file_name AS crm_source_file_name,
        c.bronze_ingest_timestamp,
        c.record_activated_at as silver_processed_at,
        current_timestamp() AS _gold_dimension_updated_at

    from silver_customer c
     left Join silver_location d
        on d.customer_id =c.customer_key
)

select * from final_dimension