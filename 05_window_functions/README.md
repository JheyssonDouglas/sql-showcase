# 05 — Window Functions

Advanced analytics using window functions — rankings, running totals, moving averages, and sequential patterns without collapsing rows.

---

## Concepts Covered

| Function                         | Description                                                  |
|----------------------------------|--------------------------------------------------------------|
| `ROW_NUMBER()`                   | Unique sequential number per partition                       |
| `RANK()` / `DENSE_RANK()`        | Rank with vs without gaps on ties                            |
| `NTILE(n)`                       | Divide rows into n equal buckets                             |
| `PERCENT_RANK()`                 | Relative rank as a 0–1 fraction                              |
| `LAG(col, n)`                    | Value from n rows behind in the window                       |
| `LEAD(col, n)`                   | Value from n rows ahead in the window                        |
| `SUM() OVER (ROWS ...)`          | Running/cumulative total                                     |
| `AVG() OVER (ROWS ...)`          | Rolling average over a sliding frame                         |
| `FIRST_VALUE()` / `LAST_VALUE()` | First/last value in a partition                              |
| `QUALIFY`                        | DuckDB-native filter on window result — no outer CTE needed  |

---

## Queries

| File | Question |
|------|----------|
| [01_customer_order_sequence.sql](01_customer_order_sequence.sql) | In what order did each customer place their orders? |
| [02_seller_revenue_ranking.sql](02_seller_revenue_ranking.sql) | How do sellers rank by revenue? RANK vs DENSE_RANK |
| [03_monthly_revenue_mom_growth.sql](03_monthly_revenue_mom_growth.sql) | What is month-over-month revenue change? |
| [04_days_between_orders.sql](04_days_between_orders.sql) | How many days between each customer's consecutive orders? |
| [05_cumulative_revenue.sql](05_cumulative_revenue.sql) | How does revenue accumulate month by month? |
| [06_rolling_order_average.sql](06_rolling_order_average.sql) | What is the 3-day rolling average of daily orders? |
| [07_customer_spend_quartiles.sql](07_customer_spend_quartiles.sql) | Which spending quartile does each customer fall into? |
| [08_seller_revenue_percentile.sql](08_seller_revenue_percentile.sql) | What revenue percentile is each seller at? |
| [09_customer_first_last_order.sql](09_customer_first_last_order.sql) | What were each customer's first and last order dates? |
| [10_latest_order_per_customer.sql](10_latest_order_per_customer.sql) | Get the most recent order per customer (QUALIFY) |
