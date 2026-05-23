{{
  config(
    materialized='materialized_view',
    schema = 'gold'
  )
}}


SELECT 
      sales_order_date AS OrderDate,
      sales_product_number As Product,
      SUM(sales_quantity) AS ProductsNumber 
FROM {{ ref('silver_sales') }}
GROUP BY sales_order_date,sales_product_number