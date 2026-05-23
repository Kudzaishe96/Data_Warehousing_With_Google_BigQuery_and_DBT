{% snapshot location_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='customer_id',
      strategy='check',
      check_cols=['country']
    )
}}

SELECT
    customer_id,
    country,
    loaded_from_file,
    dbt_ingest_timestamp
FROM {{ ref('bronze_location') }}

{% endsnapshot %}