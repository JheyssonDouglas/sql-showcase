# 03 — Aggregations

Summarizing large datasets using SQL aggregate functions.

---

## Concepts Covered

| Concept                     | Description                                                      |
|-----------------------------|------------------------------------------------------------------|
| `COUNT`, `SUM`, `AVG`       | Core aggregate functions                                         |
| `MIN`, `MAX`                | Extremes within groups                                           |
| `GROUP BY`                  | Per-group metric computation                                     |
| `HAVING`                    | Filter groups after aggregation                                  |
| `COUNT DISTINCT`            | Unique value counts                                              |
| `FILTER (WHERE ...)`        | Conditional aggregation without pivoting                         |
| `ROLLUP`                    | Hierarchical subtotals and grand total row                       |
| `DATE_TRUNC`                | Grouping timestamps by month or year                             |
| `DATEDIFF`                  | Duration between two dates                                       |

---

## Queries

| File | Question |
|------|----------|
| [01_orders_by_status.sql](01_orders_by_status.sql) | How many orders are in each status? |
| [02_revenue_by_state.sql](02_revenue_by_state.sql) | Which states generate the most revenue? |
| [03_monthly_order_volume.sql](03_monthly_order_volume.sql) | How many orders were placed each month? |
| [04_top_categories_by_revenue.sql](04_top_categories_by_revenue.sql) | Which product categories drive the most revenue? |
| [05_payment_type_analysis.sql](05_payment_type_analysis.sql) | How does payment method affect order size? |
| [06_high_volume_sellers.sql](06_high_volume_sellers.sql) | Which sellers have processed more than 100 orders? |
| [07_review_score_distribution.sql](07_review_score_distribution.sql) | How are review scores distributed? |
| [08_orders_by_status_per_state.sql](08_orders_by_status_per_state.sql) | Delivered vs canceled vs shipped per state |
| [09_revenue_rollup_by_state.sql](09_revenue_rollup_by_state.sql) | Revenue per state with grand total row |
| [10_delivery_time_by_state.sql](10_delivery_time_by_state.sql) | Avg/min/max delivery days by state |
