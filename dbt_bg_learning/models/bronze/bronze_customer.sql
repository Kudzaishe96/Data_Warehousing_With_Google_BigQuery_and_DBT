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

with source_data as (
    select
        _FILE_NAME as loaded_from_file,
        current_timestamp() as dbt_ingest_timestamp,
        
        cast(cst_id as INT64) as customer_id,
        cast(cst_key as STRING) as customer_key,
        trim(cst_firstname) as first_name,
        trim(cst_lastname) as last_name,
        cast(cst_marital_status as STRING) as marital_status,
        cast(cst_gndr as STRING) as gender,
        parse_date('%m/%d/%Y', cst_create_date) as customer_create_date
        
    from {{ source('gcs_landing', 'ext_cust_info') }}
)

select * from source_data

{% if is_incremental() %}
  where loaded_from_file not in (
      select distinct loaded_from_file 
      from {{ this }}
      where dbt_ingest_timestamp >= timestamp_sub(current_timestamp(), interval 14 day)
  )
{% endif %}