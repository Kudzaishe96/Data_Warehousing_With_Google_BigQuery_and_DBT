{{
  config(
    materialized='materialized_view'
  )
}}


SELECT 
      cst_create_date AS OpeningDate,  
      Count(cst_id) AS CustomerNumber
FROM {{ ref('bronze_customer') }}
GROUP BY cst_create_date
