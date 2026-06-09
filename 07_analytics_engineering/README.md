# 07 — Analytics Engineering

Building a production-grade dimensional model (Star Schema) from raw Olist tables using pure SQL.

---

## What is Analytics Engineering?

Analytics engineering sits between data engineering and business analytics. The goal is to transform raw data into clean, tested, well-documented models that analysts and stakeholders can trust.

This module demonstrates the core pattern: **`CREATE TABLE AS SELECT`** — the same pattern used by dbt, BigQuery, Redshift, and Snowflake to build data marts.

---

## Star Schema Design

```
                 dim_date
                    │
dim_customer ── fact_sales ── dim_seller
                    │
               dim_product
```

| Table          | Grain                     | Description                              |
|----------------|---------------------------|------------------------------------------|
| `fact_sales`   | One row per order item    | All measures: price, freight, delivery   |
| `dim_customer` | One row per unique customer| Stable customer profile with location   |
| `dim_product`  | One row per product       | Category (EN + PT), dimensions, weight   |
| `dim_seller`   | One row per seller        | Location data                            |
| `dim_date`     | One row per calendar day  | Year, month, quarter, day name, weekday  |

---

## Dimension Details

### `dim_customer`
- Uses `customer_unique_id` (stable) as the key, not `customer_id` (changes per order)
- Includes city and state for geographic analysis

### `dim_product`
- Joins the Portuguese/English category translation table
- Adds derived `weight_kg` column
- Falls back to Portuguese name if no translation exists

### `dim_date`
- Generated with `generate_series` — no dependency on order data for completeness
- Includes: year, month, quarter, day of week, weekday flag, quarter label
- Enables time-intelligence queries (same period last year, MTD, YTD)

### `fact_sales`
- Grain: one row per order item (most granular level)
- Surrogate key: `order_id + order_item_id`
- Pre-computed derived flags: `is_on_time`, `days_late`, `delivery_days`
- All foreign keys to dimensions included for join-free analytics

---

## Reporting Layer

Two example reports built directly on top of the star schema:

1. **Monthly Revenue Report** — orders, revenue, freight, delivery time, on-time %
2. **Category Performance Report** — revenue, volume, average price per category

These queries are clean and readable because the heavy lifting happened in the model layer.

---

## Skills Demonstrated

- Dimensional modeling (Star Schema)
- `CREATE TABLE AS SELECT` (CTAS) pattern
- Date spine generation with `generate_series`
- Surrogate key construction
- Pre-aggregated derived measures in the fact table
- Separation of model layer vs reporting layer

---

## File

[analytics_engineering.sql](analytics_engineering.sql)
