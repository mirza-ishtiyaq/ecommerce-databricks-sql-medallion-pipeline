# End-to-End E-Commerce Data Platform: Databricks (SQL) to Power BI

## 🏢 Executive Overview
This production-grade repository contains an end-to-end cloud data platform. **90% of data transformations, complex sanitization, schema enforcement, and structural modeling were executed upstream in Databricks utilizing Spark SQL**, pushing the heavy computational strain to the cloud data architecture[cite: 4]. The finalized gold-tier tables were then served directly to **Power BI** to enable lightweight, high-performance semantic modeling and executive reporting.

### Core Competencies Demonstrated
* **Cloud Data Architecture:** Medallion Data Design Framework (Bronze ➔ Silver ➔ Gold Tiering)
* **Analytics Engineering:** Spark SQL, Delta Lake Tables, Advanced Window Functions (`LAG`, `RANK`)
* **Data Modeling:** Relational Star Schema Optimization (Fact & Dimension Layouts)
* **Business Intelligence:** Corporate Scorecard Design, Visual UX Hierarchy, Advanced DAX

---

## Data Pipeline Architecture

```text
       [Raw Data Lake Sources (CSV)] 
                     │
                     ▼
  🟤 BRONZE LAYER : Schema Registration & Lineage Preservation (`01_bronze_ingestion.sql`)
                     │
                     ▼ (Type Casting, Relational Validation, Row Cleaning)
  ⚪ SILVER LAYER : Cleansed Relational Operational Warehouse (`02_silver_transformations.sql`)
                     │
                     ▼ (Fact Materialization, Aggregation, Star Schema Views)
  🟡 GOLD LAYER   : Analytics-Ready Enterprise Fact Tables (`03_gold_star_schema.sql`)
                     │
                     ▼ (Lightweight Semantic Modeling & High-Performance Import)
  📊 POWER BI     : Executive Financial Scorecards & Logistics Dashboard Applications
```

### 🟤 1. Bronze Layer: ACID Lakehouse Ingestion
* **Implementation:** Migrated raw multi-table transactional landing datasets into **Delta Lake** storage format inside the enterprise catalog `ecommerce_logistics`[cite: 1]. This ensures full ACID compliance and data lineage tracking.

### ⚪ 2. Silver Layer: Upstream SQL Sanitization
* **Temporal Normalization:** Used Spark SQL to transform messy text-based timestamp variables into proper database `TIMESTAMP` attributes to prepare the tracking of shipping velocities.
* **Operational Quality Checks:** Enforced relational integrity filters to eliminate rows missing vital primary keys (`order_id`, `customer_id`), cleaning out data collection defects.

### 🟡 3. Gold Layer: Dimensional Modeling & Performance Optimization
* **Performance Engineering:** Shifted complex database calculations upstream into Databricks to avoid performance issues inside the BI engine. Key intervals such as actual vs. promised transit days were calculated inside the cloud warehouse.
* **Schema Design:** Structured normalized fact tables (`master_operations`, `lost_revenue`) optimized specifically to minimize memory footprints during front-end rendering.

---

## 💡 Strategic Business Impacts & C-Suite Insights

By pre-computing the entire transformation logic inside Databricks SQL, the final Power BI dashboards render dynamically, allowing executives to filter data instantaneously:

### 📈 Dashboard Page 1: Financial & Revenue Performance Metrics
* **Critical Bottleneck Isolated:** Uncovered a structural **8.12% Revenue Leakage Rate**, showing that **$97.24K** in gross capital is locked up in canceled or unavailable order states across **$1.20M** in total pipeline revenue.
* **Corporate Action Plan:** Gives finance leaders immediate visibility to audit regional checkpoint friction and payment-gateway failure points by analyzing month-over-month traction data.

### 🚚 Dashboard Page 2: Supply Chain & Logistics Operations Scorecard
* **Critical Bottleneck Isolated:** Flagged severe nationwide courier constraints where routes to **Roraima (RO) take an unacceptable 26 days on average to fulfill**—more than double the national baseline velocity of **12.3 days**.
* **Corporate Action Plan:** Empowers regional dispatch managers to optimize underperforming freight lanes ($22.78 Average Freight Cost per Order) and actively renegotiate carrier Service Level Agreements (SLAs).

---

## 📂 Production Repository Structure
```text
├── 📂 databricks_sql_scripts/
│   ├── 01_bronze_ingestion.sql        <- Database Schema Registration & Catalog Setup
│   ├── 02_silver_transformations.sql   <- Temporal Normalization & String Cleansing
│   ├── 03_gold_star_schema.sql        <- Fact & Dimension Modeling for Data Warehousing
│   └── 04_executive_adhoc_analysis.sql <- Advanced Window Function Analytics Queries
└── 📂 power_bi_assets/
    └── Ecommerce Olist Dashboard.pbix  <- Production Dashboard Application File
```

---

## Advanced SQL Showcase: Month-over-Month Revenue Growth Velocity
This code snippet from `04_executive_adhoc_analysis.sql` showcases the complex database calculation using analytical window functions (`LAG()`) to compute historical corporate performance velocity:

```sql
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
```

---

### Author
**Mirza Ishtiyaq Baig**  
*Data Analyst / Analytics Engineer*
