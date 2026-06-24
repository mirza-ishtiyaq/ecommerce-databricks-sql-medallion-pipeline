-- ====================================================================
-- PLATFORM ARCHITECTURE: BRONZE LAYER (DATA INGESTION)
-- Objective: Migrate raw transactional landing tables into the 
-- enterprise catalog 'ecommerce_logistics' to establish data lineage.
-- Storage Engine: Delta Lake (ACID Compliant)
-- ====================================================================

CREATE SCHEMA IF NOT EXISTS ecommerce_logistics.bronze;

-- Ingesting Core Transactional Entities
CREATE OR REPLACE TABLE ecommerce_logistics.bronze.olist_orders AS
SELECT * FROM workspace.default.bronze_olist_orders;

CREATE OR REPLACE TABLE ecommerce_logistics.bronze.olist_customers AS
SELECT * FROM workspace.default.bronze_olist_customers;

CREATE OR REPLACE TABLE ecommerce_logistics.bronze.olist_order_items AS
SELECT * FROM workspace.default.bronze_olist_order_items;

-- Ingesting Core Product & Operational Catalog Dimensions
CREATE OR REPLACE TABLE ecommerce_logistics.bronze.olist_products AS
SELECT * FROM workspace.default.bronze_olist_products;

CREATE OR REPLACE TABLE ecommerce_logistics.bronze.olist_sellers AS
SELECT * FROM workspace.default.bronze_olist_sellers;

CREATE OR REPLACE TABLE ecommerce_logistics.bronze.olist_geolocation AS
SELECT * FROM workspace.default.bronze_olist_geolocation;
