{% snapshot products_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='product_id',
      strategy='check',
      check_cols=['product_number','product_cost','product_line']
    )
}}

SELECT
    product_id,
    product_key,
    product_number,
    product_cost,
    product_line,
    -- Pass these through as plain data points; do NOT monitor them for changes
    product_start_date,
    product_end_date,
    loaded_from_file,
    dbt_ingest_timestamp
FROM {{ ref('bronze_crm_products') }}

{% endsnapshot %}