{% snapshot products_erp_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='erp_products_id',
      strategy='check',
      check_cols=['erp_products_catergory','erp_products_subcatergory','erp_products_maintenance']
    )
}}

SELECT
    erp_products_id,
    erp_products_catergory,
    erp_products_subcatergory,
    erp_products_maintenance,
    loaded_from_file,
    dbt_ingest_timestamp
FROM {{ ref('bronze_erp_products') }}

{% endsnapshot %}