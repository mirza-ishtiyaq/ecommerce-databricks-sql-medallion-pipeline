-- ====================================================================
-- PLATFORM ARCHITECTURE: SILVER LAYER (TRANSFORMATION & DATA SANITIZATION)
-- Objective: Enforce high-precision schemas, handle operational nulls, 
-- and type-cast temporal indicators from text strings to timestamps.
-- ====================================================================

CREATE SCHEMA IF NOT EXISTS ecommerce_logistics.silver;

-- 1. Normalizing and Cleansing Master Orders Warehouse
CREATE OR REPLACE TABLE ecommerce_logistics.silver.olist_orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    -- High-Precision Temporal Normalization (Casting text string dates to proper timestamps)
    CAST(order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp,
    CAST(order_approved_at AS TIMESTAMP) AS order_approved_at,
    CAST(order_delivered_carrier_date AS TIMESTAMP) AS order_delivered_carrier_date,
    CAST(order_delivered_customer_date AS TIMESTAMP) AS order_delivered_customer_date,
    CAST(order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_date
FROM ecommerce_logistics.bronze.olist_orders
WHERE order_id IS NOT NULL
  AND customer_id IS NOT NULL;

-- 2. Promoting Clean Dimensional Entities (Safely moving catalogs to silver stage)
CREATE OR REPLACE TABLE ecommerce_logistics.silver.olist_customers AS
SELECT * FROM ecommerce_logistics.bronze.olist_customers;

CREATE OR REPLACE TABLE ecommerce_logistics.silver.olist_order_items AS
SELECT * FROM ecommerce_logistics.bronze.olist_order_items;

CREATE OR REPLACE TABLE ecommerce_logistics.silver.olist_sellers AS
SELECT * FROM ecommerce_logistics.bronze.olist_sellers;

CREATE OR REPLACE TABLE ecommerce_logistics.silver.olist_products AS
SELECT * FROM ecommerce_logistics.bronze.olist_products;

CREATE OR REPLACE TABLE ecommerce_logistics.silver.olist_geolocation AS
SELECT * FROM ecommerce_logistics.bronze.olist_geolocation;
