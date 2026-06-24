-- ====================================================================
-- PHASE 4: ADVANCED BUSINESS INTELLIGENCE & AD-HOC ANALYTICS
-- Objective: Execute enterprise strategic queries targeting C-Suite requests
-- utilizing analytical window functions, metrics momentum, and bottlenecks.
-- ====================================================================

-- --------------------------------------------------------------------
-- REQUEST 1 (VP OF LOGISTICS): Identify Top 5 Transit Bottleneck Lanes
-- --------------------------------------------------------------------
SELECT
    origin_state,
    destination_state,
    COUNT(order_id) AS total_orders,
    ROUND((SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END) * 100) / COUNT(*), 2) AS late_percentage
FROM ecommerce_logistics.gold.master_operations
GROUP BY origin_state, destination_state
HAVING total_orders >= 50
ORDER BY late_percentage DESC
LIMIT 5;

-- --------------------------------------------------------------------
-- REQUEST 2 (CMO): Identify Top 5 Revenue-Generating Categories & Average Price
-- --------------------------------------------------------------------
SELECT
    p.product_category_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM ecommerce_logistics.silver.olist_orders o
INNER JOIN ecommerce_logistics.silver.olist_order_items oi ON o.order_id = oi.order_id
INNER JOIN ecommerce_logistics.silver.olist_products p     ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 5;

-- --------------------------------------------------------------------
-- REQUEST 3 (VP OF SALES): Isolate the Top #1 Product Vertical per Individual State
-- --------------------------------------------------------------------
WITH ranked_regional_revenue AS (
    SELECT
        c.customer_state,
        p.product_category_name,
        ROUND(SUM(oi.price), 2) AS total_revenue,
        ROUND(COUNT(DISTINCT o.order_id), 2) AS total_orders,
        RANK() OVER (PARTITION BY c.customer_state ORDER BY SUM(oi.price) DESC) AS revenue_rank
    FROM ecommerce_logistics.silver.olist_orders o
    INNER JOIN ecommerce_logistics.silver.olist_customers c ON o.customer_id = c.customer_id
    INNER JOIN ecommerce_logistics.silver.olist_order_items oi ON o.order_id = oi.order_id
    INNER JOIN ecommerce_logistics.silver.olist_products p     ON oi.product_id = p.product_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state, p.product_category_name
)
SELECT customer_state, product_category_name, total_revenue, total_orders
FROM ranked_regional_revenue
WHERE revenue_rank = 1
ORDER BY total_revenue DESC;

-- --------------------------------------------------------------------
-- REQUEST 4 (CFO): Compute Month-Over-Month (MoM) Traction & Growth Velocity
-- --------------------------------------------------------------------
WITH monthly_revenue_ledger AS (
    SELECT
        DATE_FORMAT(CAST(o.order_purchase_timestamp AS TIMESTAMP), 'yyyy-MM') AS financial_month,
        ROUND(SUM(oi.price), 2) AS current_month_revenue,
        LAG(ROUND(SUM(oi.price), 2)) OVER (
            ORDER BY DATE_FORMAT(CAST(o.order_purchase_timestamp AS TIMESTAMP), 'yyyy-MM') ASC
        ) AS previous_month_revenue
    FROM ecommerce_logistics.silver.olist_orders o
    INNER JOIN ecommerce_logistics.silver.olist_order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY financial_month
)
SELECT
    financial_month,
    current_month_revenue,
    previous_month_revenue,
    ROUND(((current_month_revenue - previous_month_revenue) / previous_month_revenue * 100), 2) AS mom_growth_percentage
FROM monthly_revenue_ledger
ORDER BY financial_month;
