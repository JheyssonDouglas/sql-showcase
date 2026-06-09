# 04 — CTEs and Subqueries

Structuring complex analytical logic with Common Table Expressions and subqueries.

---

## Concepts Covered

| Concept                  | Description                                                          |
|--------------------------|----------------------------------------------------------------------|
| Simple CTE               | `WITH` clause to name an intermediate result set                     |
| Multiple CTEs            | Chaining `WITH cte1 AS (...), cte2 AS (...)` for multi-step logic   |
| Subquery in `WHERE`      | Scalar subquery to compare against an aggregate                      |
| Subquery in `FROM`       | Derived table for pre-computed results                               |
| Correlated subquery      | Subquery that references the outer query row-by-row                  |
| CTE + Window Function    | Combining CTEs with `LAG`, `RANK`, and `NTILE`                       |
| `NULLIF`                 | Safe division to avoid divide-by-zero errors                         |

---

## Key Queries

| # | Business Question                                                    | Technique                      |
|---|----------------------------------------------------------------------|--------------------------------|
| 1 | Which customers placed more than one order?                          | Simple CTE + HAVING            |
| 2 | What is monthly revenue and month-over-month growth?                 | CTE + LAG window function      |
| 3 | Who are the top sellers in the top 5 revenue categories?             | Multi-CTE chain                |
| 4 | Which orders exceed the average order value?                         | Subquery in WHERE (HAVING)     |
| 5 | How do states rank by revenue tier?                                  | Subquery in FROM + CASE        |
| 6 | What is each customer's most recent order?                           | Correlated subquery            |
| 7 | How are customers segmented by lifetime spend?                       | 3-step CTE chain + NTILE       |

---

## Why CTEs Over Subqueries?

CTEs improve readability by naming intermediate steps. They also enable re-use of the same result set across multiple parts of the query. Subqueries remain useful for simple scalar comparisons or derived tables that are only referenced once.

---

## File

[ctes_and_subqueries.sql](ctes_and_subqueries.sql)
