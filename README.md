# END TO END ANALYTICS WITH GOOGLE BIGQUERY,GOOGLE CLOUD AND DBT 
## ETL project using GOOGLE BIGQUERY,GOOGLE CLOUD AND DBT 

## Table Of Contents

- [ Project Overview ](#Project-Overview)
- [ DATABRICKS & DBT Architecture ](#Azure-Data-Engineering-Synapse-Analytics-Architecture)
- [ Data Source ](#Data-Source)
- [ Tools ](#Tools)
- [ Data Extraction (Bronze Layer) ](#Data-Extraction-(Bronze-Layer))
- [ Data Cleaning (Silver Layer) ](#Data-Cleaning-(Silver-Layer))
- [ Gold Layer](#Gold-Layer)


### Project Overview
The use of Google Cloud and Bigquery in conjuction with DBT

### Data Source
EMR and CMR Data csv files uploaded in the Data Source

### Tools
- Google Cloud
- Google Big Query
- DBT
- Jinja Functions

### Installation of DBT Core with Databricks
1.Using VScode , download the following extensions dbt power and materilised icons.
2.Download and install uv (pip install uv) and create a virtual environment (uv init ,uv sync).
3.Instal DBT-Core  inside the virtual and name the project (dbt-core init  dbt-bigquery init)
4.After installing dbt check for the profiles file and set the type to auoth
5.Use command dbt debug to cornfirm connection.

## Medallion Architecture

### Load Data(Bronze Layer)
1. Load csv files into Google Cloud Storage (Buckets)
2. Use cmd command dbt run-operation stage_external_sources to create external tables created from cv that are into the Google Cloud Bucket.
3. Load data using the bronze model (model/bronze) to the bronze schema while referring to external tables.

### Snapshots
1.Create snapshots for all SCD 2 to use in the silver layer and keep history data


### Data Cleaning (Silver Layer)
1. Load data from snapshots for data lineage
2. Use jinja functions ,macros and SQL for data Transformations ,data quality and intergrity.
3. Load silver tables to the silver schema.
   

  

### Gold Layer
1. Using the Kimball Model , combine tables from the silver to create dim_customers,dim_products and gold_facts while following the business rules and naming conventions
2. Use SQL joins and jinja functions to create dim_customers,dim_products and gold_facts tables ready for analytics for business use

   ### *Gold Layer Schema*
   <img width="781" height="558" alt="CRM   ERP Schema drawio" src="https://github.com/user-attachments/assets/8f9f516f-35cd-4184-886d-34c58acd296f" />

   

 #  The End
