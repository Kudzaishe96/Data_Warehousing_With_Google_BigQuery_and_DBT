-- Dimensions are materialized as static tables for fast BI querying
{{
    config(
        materialized='table', 
        schema='gold'
    )
}}

with silver_crm_products as (
    select * from {{ ref('silver_products') }} -- References your clean silver table
),

silver_erp_products AS(
    SELECT
        erp_products_id,
        erp_products_catergory,
        erp_products_subcatergory,
        erp_products_maintenance,
        loaded_from_file AS erp_source_file_name
    FROM {{ ref('silver_erp_products') }}
),

final_dimension as (
    select
        -- 1. Generate the Primary Surrogate Key for the Product Dimension
        {{ dbt_utils.generate_surrogate_key(['p.product_id']) }} as product_sk,
        
        -- 2. Cleaned Keys and IDs
        p.product_id,
        p.product_key,
        p.catergory_id as category_id, -- Standardizing the naming convention here if needed
        p.product_number,
        
        -- 3. Descriptive Attributes for BI Reporting
        p.product_name,
        p.product_colour as product_color,
        p.product_line,
        c.erp_products_catergory,
        c.erp_products_subcatergory,
        c.erp_products_maintenance,
        
        
        -- 4. Formatted Financial Metrics
        cast(p.product_cost as numeric) as product_cost,
        
        -- 5. Tracked Validity Dates
        p.product_start_date,
        p.product_end_date,
        
        -- 6. Audit Metadata Traceability
        c.erp_source_file_name,
        p.source_file_name AS crm_source_file_name,
        current_timestamp() as _gold_dimension_updated_at

    from silver_crm_products p
    left Join silver_erp_products c
        on c.erp_products_id=p.catergory_id
)
select * from final_dimension