{{
    config(
        materialized='incremental',
        incremental_strategy='insert_overwrite',
        partition_by={
            "field": "dbt_ingest_timestamp",
            "data_type": "timestamp",
            "granularity": "day"
        },
        cluster_by=["loaded_from_file"]
    )
}}

WITH source_data AS(
        select
        _FILE_NAME as loaded_from_file,
        current_timestamp() as dbt_ingest_timestamp,
        cast(sls_ord_num as STRING) as sales_order_number,
        cast(sls_prd_key as STRING) as sales_product_number,
        cast(sls_cust_id as INT64) as sales_customer_id,
        safe.parse_date('%Y%m%d', sls_order_dt)as sales_order_date,
        safe.parse_date('%Y%m%d',sls_ship_dt ) as sales_ship_date,
        safe.parse_date('%Y%m%d',sls_due_dt) as sales_due_date,
        cast(sls_sales as FLOAT64) as sales,
        cast(sls_quantity as INT64) as sales_quantity,
        cast(sls_price as FLOAT64) as sales_price
        
    from {{ source('gcs_landing', 'ext_sales') }}
)

select * from source_data

{% if is_incremental() %}
  where loaded_from_file not in (
      select distinct loaded_from_file 
      from {{ this }}
      where dbt_ingest_timestamp >= timestamp_sub(current_timestamp(), interval 14 day)
  )
{% endif %}