-- ====================================================================
-- PLATFORM ARCHITECTURE: GOLD LAYER (ANALYTICAL MODELING & STAR SCHEMA)
-- Objective: Construct indexed Fact tables optimized for maximum BI 
-- DirectQuery/Import semantic performance by joining dimension catalogs.
-- ====================================================================

CREATE SCHEMA IF NOT EXISTS ecommerce_logistics.gold;

-- 1. Constructing Master Operations Logistics Fact Table
CREATE OR REPLACE TABLE ecommerce_logistics.gold.master_operations AS
SELECT
    o.order_id,
    o.order_status,
    oi.product_id,
    oi.price,
    oi.freight_value,
    c.customer_state AS destination_state,
    s.seller_state AS origin_state,
    p.product_weight_g,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    -- Upstream performance modeling: Pre-calculating transit day intervals
    DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) AS actual_delivery_days,
    DATEDIFF(o.order_estimated_delivery_date, o.order_purchase_timestamp) AS promised_delivery_days,
    -- Upstream SLA performance flag
    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
        ELSE 'On-Time'
    END AS delivery_status
FROM ecommerce_logistics.silver.olist_orders o
LEFT JOIN ecommerce_logistics.silver.olist_order_items oi   ON o.order_id = oi.order_id
LEFT JOIN ecommerce_logistics.silver.olist_customers c     ON o.customer_id = c.customer_id
LEFT JOIN ecommerce_logistics.silver.olist_sellers s       ON oi.seller_id = s.seller_id
LEFT JOIN ecommerce_logistics.silver.olist_products p       ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;

-- 2. Constructing Financial Leakage Fact Table (Capital At Risk)
CREATE OR REPLACE TABLE ecommerce_logistics.gold.lost_revenue AS
SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    COALESCE(oi.price, 0) AS lost_item_revenue
FROM ecommerce_logistics.silver.olist_orders o
LEFT JOIN ecommerce_logistics.silver.olist_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status IN ('canceled', 'unavailable');
