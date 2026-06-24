# End-to-End E-Commerce Data Platform: Databricks (SQL) to Power BI

## Project Summary
This repository contains a complete data pipeline built to ingest, clean, and model e-commerce data. To keep the Power BI report fast and lightweight, 90% of the heavy data transformation and data warehousing logic was handled upstream inside Databricks using Spark SQL. Power BI was used purely as a clean presentation and reporting layer.

### Key Skills
* **Data Architecture:** Medallion framework design (Bronze, Silver, and Gold layers).
* **Data Engineering:** Query optimization, Delta Lake management, and advanced Spark SQL.
* **Data Modeling:** Building analytical star schemas (Fact and Dimension tables).
* **Business Intelligence:** Preparing report views, dashboard UX design, and DAX modeling.

---

## Data Pipeline Flow

```text
       [Raw CSV Files] 
                 │
                 ▼
      🟤 BRONZE LAYER : Raw Data Ingestion & Storage (`01_bronze_ingestion.sql`)
                 │
                 ▼ (Data Cleaning, Schema Validation, Handling Nulls)
      ⚪ SILVER LAYER : Cleaned Operational Tables (`02_silver_transformations.sql`)
                 │
                 ▼ (Joining Tables & Building Star Schema Views)
      🟡 GOLD LAYER   : Analytics-Ready Fact Tables (`03_gold_star_schema.sql`)
                 │
                 ▼ (Optimized Connection for Reporting)
      📊 POWER BI     : High-Performance Executive Dashboards
```

### 🟤 1. Bronze Layer: Raw Data Ingestion
* **What was done:** Imported multi-table operational e-commerce data directly into Databricks as **Delta Lake** tables. This secured the raw data layout, ensured ACID compliance, and preserved clear data lineage.

### ⚪ 2. Silver Layer: Upstream SQL Cleaning
* **Fixing Timestamps:** Converted text-based date columns into structured standard `TIMESTAMP` formats to calculate shipping speeds accurately.
* **Data Quality Checks:** Filtered out incomplete or corrupted rows missing critical keys like `order_id` or `customer_id` to safeguard relational integrity.

### 🟡 3. Gold Layer: Data Warehousing & Modeling
* **Pre-calculating Metrics:** Moved resource-heavy calculations (like actual vs. estimated delivery days) directly into the cloud warehouse. This eliminated calculation lag on the front end.
* **Star Schema Layout:** Organized rows into optimized fact tables (`master_operations` and `lost_revenue`) to keep the BI import sizes compact and highly responsive.

<img width="1920" height="1080" alt="data_model" src="https://github.com/user-attachments/assets/dbed483f-2eec-4808-89ee-9b04bf4d7ae5" />


---

## 💡 Business Insights & Impact

By executing the heavy transformations inside Databricks SQL, the final Power BI dashboard functions instantly without latency:

### 📈 Financial & Revenue Performance
* **The Problem:** Found an **8.12% Revenue Leakage Rate**, showing that **$97.24K** in revenue is lost or stuck in canceled/unavailable orders out of **$1.20M** total gross pipeline revenue.
* **The Solution:** Financial teams can track leakage trends month-over-month to audit and fix payment gateway or checkout bugs.

<img width="1920" height="1080" alt="page1_finance" src="https://github.com/user-attachments/assets/bd6da027-046f-4603-bbc8-79d547652402" />


### 🚚 Supply Chain & Logistics Operations
* **The Problem:** Flagged major delivery issues where shipments to **Roraima (RO) take an average of 26 days**—more than double the national average baseline of **12.3 days**.
* **The Solution:** Supply chain managers can quickly spot failing transit paths ($22.78 average freight cost per order) and renegotiate contract carrier terms.

<img width="1920" height="1080" alt="page2_logistics" src="https://github.com/user-attachments/assets/eaf86c8d-ac11-4211-8668-0716a557cf37" />


---

## 📂 Folder Layout
```text
├── 📂 databricks_sql_scripts/
│   ├── 01_bronze_ingestion.sql        <- Raw Data Landing & Catalog Mapping
│   ├── 02_silver_transformations.sql   <- Data Type Conversion & Null Handling
│   ├── 03_gold_star_schema.sql        <- Analytical Star Schema Layouts
│   └── 04_executive_adhoc_analysis.sql <- Business Analysis Queries
└── 📂 power_bi_assets/
    ├── Ecommerce Olist Dashboard.pbix  <- Final Report File
    └── 📂 documentation_images/       <- Embedded Dashboard Screenshots
```

---

## Advanced SQL Sample: Month-over-Month Growth Calculation
This snippet from `04_executive_adhoc_analysis.sql` shows how historical performance velocity is tracked using SQL window functions (`LAG`):

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
**Mirza Ishtiyaq Baig** *Data Analyst / Analytics Engineer*
