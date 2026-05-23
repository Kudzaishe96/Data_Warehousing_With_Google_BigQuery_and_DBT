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
        cast(prd_id as INT64) as product_id,
        cast(prd_key as STRING) as product_key,
        trim(prd_nm) as product_number,
        cast(prd_cost as INT64) as product_cost,
        cast(prd_line as STRING) as product_line,
        parse_date('%Y-%m-%d', prd_start_dt) as product_start_date,
        parse_date('%Y-%m-%d', prd_end_dt) as product_end_date
        
    from {{ source('gcs_landing', 'ext_prd_info') }}
)

select * from source_data

{% if is_incremental() %}
  where loaded_from_file not in (
      select distinct loaded_from_file 
      from {{ this }}
      where dbt_ingest_timestamp >= timestamp_sub(current_timestamp(), interval 14 day)
  )
{% endif %}