{{
  config(
    materialized='materialized_view',
    schema = 'gold'
  )
}}


SELECT 
      customer_create_date AS OpeningDate,
      gender As Gender,
      Count(customer_id) AS CustomerNumber
FROM {{ ref('silver_customer') }}
GROUP BY customer_create_date,gender