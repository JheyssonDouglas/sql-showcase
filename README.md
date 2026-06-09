# SQL Showcase — Olist E-Commerce Analytics

> End-to-end SQL analysis of Brazil's largest public e-commerce dataset, demonstrating skills from fundamentals to production-grade analytics engineering.

![SQL](https://img.shields.io/badge/SQL-DuckDB-yellow?logo=duckdb)
![Dataset](https://img.shields.io/badge/Dataset-Olist%20E--Commerce-blue)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

---

## Overview

This repository is a structured SQL portfolio built on the **Brazilian E-Commerce Public Dataset by Olist** — a real dataset with over 100,000 orders, 99k customers, 3k sellers, and 32k products.

The project covers the full analytical lifecycle:

- Data exploration and validation
- Core SQL techniques (joins, aggregations, window functions)
- Business analytics with real KPIs
- Analytics engineering with dimensional modeling
- Query optimization and performance analysis

---

## Dataset Schema

```
customers ──────── orders ─────────── order_items ──── products
    (customer_id)      (order_id)           (order_id)      (product_id)
                           │                    │
                           │               order_items ──── sellers
                           │                                (seller_id)
                    order_payments
                    order_reviews
```

| Table                | Rows    | Description                        |
|----------------------|---------|------------------------------------|
| customers            | 99,441  | Customer records with location     |
| orders               | 99,441  | Orders with status and timestamps  |
| order_items          | 112,650 | Products sold within each order    |
| products             | 32,951  | Product catalog with categories    |
| sellers              | 3,095   | Marketplace seller information     |
| order_payments       | 103,886 | Payment method and installments    |
| order_reviews        | 99,224  | Customer satisfaction scores       |

---

## Project Structure

```
sql-showcase/
├── 00_data_understanding/      # Schema exploration and relationship validation
├── 01_select_and_filtering/    # SELECT, WHERE, ORDER BY, LIKE, BETWEEN, IN
├── 02_joins/                   # INNER, LEFT, multiple joins, anti-join patterns
├── 03_aggregations/            # GROUP BY, HAVING, COUNT, SUM, AVG, ROLLUP
├── 04_ctes_and_subqueries/     # CTEs, correlated subqueries, multi-step logic
├── 05_window_functions/        # ROW_NUMBER, RANK, LAG/LEAD, running totals
├── 06_business_cases/          # Real KPIs: revenue, RFM, LTV, delivery SLA
├── 07_analytics_engineering/   # Dimensional modeling: fact + dim tables
├── 08_query_optimization/      # Performance rewrites and EXPLAIN analysis
├── database/
│   └── setup.sql               # DuckDB setup script
└── datasets/                   # Olist CSV files
```

---

## Sections

### [00 — Data Understanding](00_data_understanding/)
Schema exploration, primary/foreign key validation, relationship mapping, and business question formulation before any analytical work.

### [01 — SELECT and Filtering](01_select_and_filtering/)
Foundational query patterns: column selection, row filtering, pattern matching, null handling, and sorting. Covers `WHERE`, `LIKE`, `BETWEEN`, `IN`, `IS NULL`, `ORDER BY`, `DISTINCT`.

### [02 — JOINs](02_joins/)
Combining data across tables: `INNER JOIN`, `LEFT JOIN`, multi-table joins, and anti-join patterns using `LEFT JOIN ... WHERE IS NULL`.

### [03 — Aggregations](03_aggregations/)
Summarizing data at scale: `GROUP BY`, `HAVING`, `COUNT DISTINCT`, revenue rollups, and `ROLLUP` for subtotals.

### [04 — CTEs and Subqueries](04_ctes_and_subqueries/)
Multi-step logic with `WITH` clauses, scalar subqueries, subqueries in `FROM` and `WHERE`, correlated subqueries, and chained CTEs.

### [05 — Window Functions](05_window_functions/)
Advanced analytics: `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`/`LEAD`, running totals, moving averages, `NTILE`, and `PERCENT_RANK`.

### [06 — Business Cases](06_business_cases/)
Real-world KPIs: monthly revenue, YoY growth, customer RFM segmentation, seller performance scorecard, delivery SLA analysis, and LTV estimation.

### [07 — Analytics Engineering](07_analytics_engineering/)
Dimensional modeling in SQL: building `dim_customer`, `dim_product`, `dim_seller`, `dim_date`, and `fact_sales` from raw tables using `CREATE TABLE AS SELECT`.

### [08 — Query Optimization](08_query_optimization/)
Performance-focused rewrites: eliminating `SELECT *`, early filtering, index recommendations, CTE vs subquery trade-offs, and `EXPLAIN` output analysis.

---

## Setup

**Requirements:** [DuckDB CLI](https://duckdb.org/docs/installation/) or any DuckDB-compatible client (DBeaver, VSCode extension).

1. Clone this repository
2. Download the dataset from [Kaggle — Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and place the CSV files in the `datasets/` folder
3. Run the setup script to create the database:

```bash
duckdb database/olist.duckdb < database/setup.sql
```

4. Open any `.sql` file and run queries against `database/olist.duckdb`

---

## Skills Demonstrated

| Area                      | Tools / Concepts                                      |
|---------------------------|-------------------------------------------------------|
| SQL Fundamentals          | SELECT, WHERE, JOIN, GROUP BY, ORDER BY               |
| Advanced SQL              | Window Functions, CTEs, Subqueries, ROLLUP            |
| Business Analytics        | KPI design, RFM, LTV, cohort-style analysis           |
| Analytics Engineering     | Star schema, fact/dim modeling, `CREATE TABLE AS`     |
| Query Performance         | EXPLAIN, index strategy, query rewriting              |
| Data Platform             | DuckDB, columnar storage, CSV ingestion               |

---

## Author

**Jheysson Douglas**
Analytics Engineer | Data Engineer

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://linkedin.com/in/jheyssondouglas)
[![GitHub](https://img.shields.io/badge/GitHub-Profile-black?logo=github)](https://github.com/jheyssondouglas)
