SELECT 
*
FROM 
{{ source('dbt_learn', 'customers') }}