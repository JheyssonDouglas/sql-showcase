# 03 — Aggregations

Summarizing and analyzing large datasets using SQL aggregate functions on the Olist dataset.

---

## Concepts Covered

| Concept                      | Description                                                       |
|------------------------------|-------------------------------------------------------------------|
| `COUNT`, `SUM`, `AVG`        | Core aggregate functions                                          |
| `MIN`, `MAX`                 | Extremes within groups                                            |
| `GROUP BY`                   | Grouping rows to compute per-group metrics                        |
| `HAVING`                     | Filtering groups after aggregation (like WHERE but for groups)    |
| `COUNT DISTINCT`             | Counting unique values                                            |
| `FILTER (WHERE ...)`         | Conditional aggregation without pivoting the query                |
| `ROLLUP`                     | Hierarchical subtotals and grand totals                           |
| Window in aggregation        | `SUM(...) OVER ()` to compute percentages of total inline         |
| `DATE_TRUNC`                 | Grouping timestamps by month/year                                 |
| `DATEDIFF`                   | Computing duration between two dates                              |

---

## Key Queries

| # | Business Question                                         | Technique                   |
|---|-----------------------------------------------------------|-----------------------------|
| 1 | What percentage of orders is in each status?              | GROUP BY + window percentage |
| 2 | Which states generate the most revenue?                   | Multi-table GROUP BY         |
| 3 | How many orders per month?                                | DATE_TRUNC + GROUP BY        |
| 4 | Which product categories drive the most revenue?          | JOIN + GROUP BY + COALESCE   |
| 5 | How does payment type affect average order value?         | GROUP BY payment_type        |
| 6 | Which sellers have more than 100 orders?                  | HAVING filter                |
| 7 | How are review scores distributed?                        | GROUP BY + window percentage |
| 8 | How many orders per status per state?                     | Conditional aggregation      |
| 9 | Revenue subtotals by state with grand total               | ROLLUP                       |
| 10| What is avg/min/max delivery time by state?               | DATEDIFF + GROUP BY          |

---

## File

[aggregations.sql](aggregations.sql)
