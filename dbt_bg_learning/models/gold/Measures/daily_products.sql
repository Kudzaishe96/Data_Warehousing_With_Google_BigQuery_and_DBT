{{
  config(
    materialized='materialized_view',
    schema = 'gold'
  )
}}


SELECT 
      product_name AS ProductName,
      product_colour As ProductColour,
      Count(product_id) AS Products
FROM {{ ref('silver_products') }}
GROUP BY product_name,product_colour