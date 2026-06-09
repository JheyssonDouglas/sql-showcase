# 05 — Window Functions

Advanced analytics using SQL window functions — computing rankings, running totals, moving averages, and sequential patterns without collapsing rows.

---

## Concepts Covered

| Function                    | Description                                                    |
|-----------------------------|----------------------------------------------------------------|
| `ROW_NUMBER()`              | Unique sequential number per partition                         |
| `RANK()`                    | Position with gaps on ties                                     |
| `DENSE_RANK()`              | Position without gaps on ties                                  |
| `NTILE(n)`                  | Divide rows into n equal-sized buckets                         |
| `PERCENT_RANK()`            | Relative rank as a 0–1 fraction                                |
| `LAG(col, n)`               | Value from n rows behind in the window                         |
| `LEAD(col, n)`              | Value from n rows ahead in the window                          |
| `SUM() OVER (... ROWS ...)`  | Running/cumulative total with explicit frame                   |
| `AVG() OVER (... ROWS ...)`  | Rolling average over a sliding window frame                    |
| `FIRST_VALUE()` / `LAST_VALUE()` | First/last value in a partition window                   |
| `QUALIFY`                   | DuckDB-native filter on window function result (no outer CTE)  |

---

## Key Queries

| # | Business Question                                                   | Technique                        |
|---|---------------------------------------------------------------------|----------------------------------|
| 1 | What is the sequence number of each customer's orders?              | ROW_NUMBER PARTITION BY customer |
| 2 | How do sellers rank by revenue, handling ties?                      | RANK vs DENSE_RANK               |
| 3 | What is month-over-month revenue change?                            | LAG with percent change          |
| 4 | How many days between consecutive orders per customer?              | LEAD with DATEDIFF               |
| 5 | What is the cumulative revenue over time?                           | SUM OVER with UNBOUNDED frame    |
| 6 | What is the 3-day rolling average of daily orders?                  | AVG OVER ROWS 2 PRECEDING        |
| 7 | Which spend quartile does each customer fall into?                  | NTILE(4) + CASE labeling         |
| 8 | What revenue percentile is each seller at?                          | PERCENT_RANK                     |
| 9 | What was each customer's first and last order date?                 | FIRST_VALUE / LAST_VALUE         |
| 10| Get the latest order per customer efficiently                       | QUALIFY + ROW_NUMBER             |

---

## Window Frame Cheatsheet

```sql
-- All rows from partition start to current row
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

-- 3-row rolling window (current + 2 before)
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW

-- Full partition (for FIRST_VALUE/LAST_VALUE correctness)
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
```

---

## File

[window_functions.sql](window_functions.sql)
