{{
  config(
    materialized='materialised_view'
  )
}}


SELECT 
      cst_create_date AS OpeningDate,  
      Count(cst_id) AS CustomerNumber
FROM {{ ref('bronze_customers') }}
WHERE cst_create_date <= '2026-05-20'
GROUP BY cst_create_date
--ORDER BY cst_id, cst_create_date ASC