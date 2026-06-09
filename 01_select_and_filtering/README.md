# 01 — SELECT and Filtering

Foundational query patterns for selecting, filtering, and sorting data from the Olist dataset.

---

## Concepts Covered

| Concept          | Description                                               |
|------------------|-----------------------------------------------------------|
| `SELECT`         | Column selection and aliasing                             |
| `WHERE`          | Row-level filtering                                       |
| `AND` / `OR`     | Compound conditions                                       |
| `IN` / `NOT IN`  | List-based filtering                                      |
| `BETWEEN`        | Numeric and date range filtering                          |
| `ILIKE`          | Case-insensitive pattern matching                         |
| `IS NULL`        | Identifying and excluding missing values                  |
| `DISTINCT`       | Removing duplicate values                                 |
| `ORDER BY`       | Sorting results                                           |
| `LIMIT / OFFSET` | Pagination                                                |

---

## Queries

| File | Question |
|------|----------|
| [01_customer_overview.sql](01_customer_overview.sql) | What does a customer record look like? |
| [02_delivered_orders.sql](02_delivered_orders.sql) | Which orders have been delivered? |
| [03_problematic_orders.sql](03_problematic_orders.sql) | Which orders are canceled, unavailable, or processing? |
| [04_products_by_weight.sql](04_products_by_weight.sql) | Which products weigh between 500g and 2kg? |
| [05_electronics_categories.sql](05_electronics_categories.sql) | Which categories are electronics-related? |
| [06_orders_missing_approval.sql](06_orders_missing_approval.sql) | Which orders were never approved? |
| [07_order_status_breakdown.sql](07_order_status_breakdown.sql) | How many distinct statuses and unique customers exist? |
| [08_sp_delivered_orders_2018.sql](08_sp_delivered_orders_2018.sql) | Delivered orders from São Paulo in 2018 |
