{{
  config(
    materialized='materialized_view',
    schema='gold'
  )
}}

SELECT 
    sales_ship_date AS ShipDate,
    sales_product_number AS Product,
    -- Fixed nested aggregate: This calculates the total units shipped per group
    SUM(sales_quantity) AS CustomerNumber 
FROM {{ ref('silver_sales') }}
GROUP BY sales_ship_date, sales_product_number