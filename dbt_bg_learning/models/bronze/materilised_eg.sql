{{
  config(
    materialized='materialized_view'
  )
}}


SELECT 
      cst_create_date AS OpeningDate,  
      Count(cst_id) AS CustomerNumber
FROM {{ ref('bronze_customers') }}
GROUP BY cst_create_date
