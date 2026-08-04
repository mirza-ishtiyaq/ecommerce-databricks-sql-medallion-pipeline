# E-Commerce Fulfilment Medallion Pipeline

![Star Schema Data Model](./docs/images/data_model.png)

---

## The Question

In a $1.20M e-commerce pipeline, why is **$97.24K (8.12%)** of gross revenue trapped in canceled and unavailable order states? And why do regional delivery times in remote states average **26 days** — more than double the **12.3-day** national baseline — driving up freight costs and customer friction?

Reporting directly off raw transactional databases created two bottlenecks: dashboard query latency and fragmented business logic pushed into Power BI instead of being resolved upstream in the warehouse.

---

## The Data

Simulated operational datasets: the public [Brazilian E-Commerce (Olist) dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — **~99,000 real orders** across customers, orders, items, products, sellers, and geolocation tables.

> **Note:** Raw CSVs are **not** checked into this repo due to file size (`data/datasets/` is an intentionally empty placeholder). Download the dataset from Kaggle and land it in your own Bronze source location to reproduce the pipeline end-to-end.

---

## The Stack

| Layer | Tool |
|---|---|
| **Data Platform** | Databricks / Spark SQL |
| **Storage Format** | Delta Lake (ACID-compliant) |
| **Data Warehousing** | Medallion Architecture (Bronze → Silver → Gold) |
| **Business Intelligence** | Power BI (Import Mode / Star Schema Data Model) |

```text
       [Raw Transactional & Operational Extracts]
                         │
                         ▼
       BRONZE LAYER     : Raw Delta Lake Migration (01_bronze_ingestion.sql)
                         │
                         ▼ (Timestamp Parsing, Schema Enforcement, Null Filtering)
       SILVER LAYER     : Cleaned Operational Tables (02_silver_transformations.sql)
                         │
                         ▼ (Star Schema Joins & Upstream Performance Pre-Calculations)
       GOLD LAYER       : Production Fact Tables (03_gold_star_schema.sql)
                         │
                         ▼ (Lightweight Import / DirectQuery)
       POWER BI         : Executive Financial & Logistics Dashboards
```

---

## What It Found

| Finding | Value |
|---|---|
| **Unrealised revenue surfaced** | **$97.24K** trapped in canceled/unavailable order states — **8.12%** of a **$1.20M** gross pipeline |
| **Transit outlier** | **26-day** regional delivery average vs a **12.3-day** national baseline |
| **Transformations pushed upstream** | **90%** of data cleaning, temporal conversions, and star-schema modeling moved from Power BI into the Databricks warehouse |
| **Dashboard labeling bug caught** | The 26-day bottleneck state is Rondônia ("RO"), not Roraima ("RR") as originally mislabeled — corrected under independent review |

![Executive Financial Performance Dashboard](./docs/images/page1_finance.png)
![Logistics & Supply Chain Dashboard](./docs/images/page2_logistics.png)

**Stakeholder summary:** Finance can act on a documented **$97.24K leakage figure** today. Logistics should investigate **Rondônia specifically** before renegotiating carrier contracts on that lane.

---

## How to Run It

### Prerequisites
- **Databricks** workspace (Community Edition works for SQL execution)
- **Power BI Desktop** (Windows) for the interactive dashboard
- Download the [Olist dataset from Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

### Step-by-step

```bash
# 1. Clone the repository
git clone https://github.com/mirza-ishtiyaq/databricks-medallion-architecture.git
cd databricks-medallion-architecture

# 2. Upload Olist CSV files to your Databricks workspace
# Place the downloaded Kaggle CSVs in your DBFS or Unity Catalog volume
```

```sql
-- 3. Execute the SQL pipeline in Databricks SQL Worksheet, in order:

-- Step 1: Ingest raw data into Bronze Delta tables
-- Run: sql/01_bronze_ingestion.sql

-- Step 2: Clean and transform into Silver layer
-- Run: sql/02_silver_transformations.sql

-- Step 3: Build Gold star schema with pre-computed metrics
-- Run: sql/03_gold_star_schema.sql

-- Step 4: Run executive ad-hoc analysis queries
-- Run: sql/04_executive_adhoc_analysis.sql
```

```text
# 4. Open the Power BI dashboard
# File: dashboards/Ecommerce Olist Dashboard.pbix
# Open in Power BI Desktop → the star schema will render automatically
# Explore Page 1 (Financial) and Page 2 (Logistics)
```

---

## Repository Structure

```
databricks-medallion-architecture/
├── README.md
├── LICENSE
├── dashboards/
│   └── Ecommerce Olist Dashboard.pbix
├── data/
│   └── datasets/                              # Intentionally empty — download from Kaggle
├── docs/
│   └── images/
│       ├── data_model.png
│       ├── page1_finance.png
│       └── page2_logistics.png
└── sql/
    ├── 01_bronze_ingestion.sql
    ├── 02_silver_transformations.sql
    ├── 03_gold_star_schema.sql
    └── 04_executive_adhoc_analysis.sql
```

---

**Author:** Mirza Ishtiyaq Baig
**LinkedIn:** https://www.linkedin.com/in/mirzaishtiyaqbaig/
**GitHub:** https://github.com/mirza-ishtiyaq
