{{
  config(
    materialized='materialized_view',
    schema = 'gold'
  )
}}


SELECT 
      sales_due_date AS DueDate,
      sales_product_number As Product,
      SUM(sales_quantity) AS ProductsNumber
FROM {{ ref('silver_sales') }}
GROUP BY sales_due_date,sales_product_number