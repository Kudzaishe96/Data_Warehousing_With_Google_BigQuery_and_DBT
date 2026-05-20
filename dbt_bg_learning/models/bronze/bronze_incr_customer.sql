{{
  config(
    materialized='incremental',
    unique_key='cst_id',
    incremental_strategy='merge'
  )
}}

WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY cst_id 
               ORDER BY cst_create_date DESC
           ) AS flag
    FROM {{ source('dbt_learn', 'customers') }}
    WHERE cst_id IS NOT NULL
)
SELECT DISTINCT
       cst_id,
       cst_key,
       cst_firstname,
       cst_lastname,
       cst_marital_status,
       cst_gndr,
       cst_create_date
FROM ranked
WHERE flag = 1
ORDER BY cst_id, cst_create_date ASC