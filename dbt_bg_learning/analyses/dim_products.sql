SELECT *
FROM {{ ref('dim_products') }}

SELECT * FROM
{{ ref('facts_sales') }}

SELECT Distinct erp_products_catergory from {{ ref('silver_erp_products') }}

SELECT * FROM {{ ref('silver_erp_products') }}

SELECT * FROM {{ ref('silver_products') }}
SELECT * FROM {{ ref('silver_sales') }}

SELECT * from {{ ref('silver_customer') }}

SELECT customer_id,count(customer_id) AS Duplicates FROM {{ ref('bronze_customer') }}
GROUP BY customer_id
HAVING count(customer_id) >1

SELECT * FROM {{ ref('bronze_customer') }}

SELECT * FROM {{ ref('location_snapshot') }}