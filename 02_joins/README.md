# 02 — JOINs

Combining data across multiple tables using different join strategies on the Olist dataset.

---

## Concepts Covered

| Concept              | Description                                                        |
|----------------------|--------------------------------------------------------------------|
| `INNER JOIN`         | Returns only rows with matches in both tables                      |
| `LEFT JOIN`          | Returns all left-table rows, NULLs for unmatched right rows        |
| Multi-table JOIN     | Chaining 3+ joins in a single query                                |
| Anti-JOIN            | `LEFT JOIN ... WHERE right.id IS NULL` to find unmatched rows      |
| JOIN + Aggregation   | Combining joins with `GROUP BY` for summary metrics                |
| `COALESCE` with JOIN | Handling NULLs from unmatched join rows                            |

---

## Key Queries

| # | Business Question                                              | Technique             |
|---|----------------------------------------------------------------|-----------------------|
| 1 | What city and state is each customer order from?               | INNER JOIN            |
| 2 | Which orders have no customer review?                          | LEFT JOIN + NULL check|
| 3 | Are there orders with no payment record?                       | Anti-JOIN             |
| 4 | What product category and seller state is each item from?      | 3-table INNER JOIN    |
| 5 | What is the complete picture of a single order?                | 7-table JOIN          |
| 6 | What is total revenue and order count per seller?              | JOIN + GROUP BY       |
| 7 | What are product categories in English?                        | LEFT JOIN + COALESCE  |
| 8 | Which approved orders were never shipped?                      | Filtered LEFT JOIN    |

---

## File

[joins.sql](joins.sql)
