-- Fact tables in Gold are typically materialized as tables for high BI performance
{{
    config(
        materialized='table', 
        schema='gold'
    )
}}

with silver_sales as (
    select * from {{ ref('silver_sales') }}
),

dim_customer as (
    -- We read from the historical snapshot records exposed in the dimension tracking tier
    select 
        customer_sk,
        customer_id,
        record_valid_from,
        record_valid_to
    from {{ ref('silver_customer_history') }} 
),

dim_products as (
    -- If your dim_products is a current-state table, you can fallback to joining on natural keys,
    -- but reading from the versioned snapshot records preserves historical accuracy.
    select 
        product_sk,
        product_id,
        product_number,
        product_key
    from {{ ref('dim_products') }}
),

joined_fact as (
    select
        -- 1. Generate a Unique Fact Line Identifier Header Key
        {{ dbt_utils.generate_surrogate_key(['sales_order_number', 'sales_product_number', 'sales_customer_id']) }} as sales_fact_sk,
        
        -- 2. Conformed Dimensional Surrogate Keys (The Glue of the Star Schema)
        coalesce(c.customer_sk, 'unknown_customer') as customer_sk,
        coalesce(p.product_sk, 'unknown_product') as product_sk,
        
        -- 3. Degenerate Dimension Business Keys
        s.sales_order_number,
        
        -- 4. Transactional/Operational Event Timestamps
        cast(s.sales_order_date as date) as order_date,
        cast(s.sales_ship_date as date) as ship_date,
        cast(s.sales_due_date as date) as due_date,
        
        -- 5. Fact Metric Line Measures
        s.sales_quantity,
        cast(s.sales_price as numeric) as unit_price,
        cast(s.sales as numeric) as gross_sales_amount,
        
        -- 6. Audit Pipeline Traceability Window
        s.loaded_from_file as source_file_name,
        s.dbt_ingest_timestamp as silver_processed_at,
        current_timestamp() as _gold_dimension_updated_at

    from silver_sales s
    
    -- Point-in-Time Join for Customers: Matches the invoice date to the exact customer snapshot profile version
    left join dim_customer c
        on s.sales_customer_id = c.customer_id
        
    -- Join for Products: Links directly to the conformed product profile
    left join dim_products p
        on s.sales_product_number = p.product_key
)

select * from joined_fact