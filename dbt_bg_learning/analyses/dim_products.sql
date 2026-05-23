SELECT *
FROM {{ ref('dim_products') }}

SELECT * FROM
{{ ref('facts_sales') }}