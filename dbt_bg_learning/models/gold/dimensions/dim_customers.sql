--Gold dimensions are best built as full tables for BI performance
{{
    config(
        materialized='table',  
        schema='gold'
    )
}}

with silver_data as (
    select * from {{ ref('silver_customer') }} -- References your clean silver table
),

final_dimension as (
    select
        -- 1. Generate a clean Surrogate Key for the Gold Dimension
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_sk,
        
        -- 2. Business Keys & Natural Attributes
        customer_id,
        customer_key,
        first_name,
        last_name,
        -- Creating a useful concatenated field for easy searching in Power BI
        concat(first_name, ' ', last_name) as full_name,
        
        marital_status,
        gender,
        customer_create_date,
        
        -- 3. Audit Metadata preserved for backend support
        source_file_name,
        bronze_ingest_timestamp,
        record_activated_at as silver_processed_at,
        dbt_scd_id as source_version_hash

    from silver_data
)

select * from final_dimension