# 08 — Query Optimization

Writing performance-aware SQL through before/after comparisons. Each example shows a common anti-pattern and the preferred alternative.

---

## Why Optimization Matters

On datasets with millions of rows in production (BigQuery, Redshift, Snowflake), poorly written queries can cost orders of magnitude more in time and money. These patterns apply regardless of the SQL engine.

---

## Patterns Covered

| # | Anti-Pattern                            | Better Approach                              | Impact                                 |
|---|-----------------------------------------|----------------------------------------------|----------------------------------------|
| 1 | `SELECT *`                              | Select only needed columns                   | Reduced I/O in columnar storage        |
| 2 | Filter after aggregation                | Filter inside CTE / use `HAVING`             | Fewer rows to aggregate                |
| 3 | Repeated subqueries                     | Compute once in a CTE, reference by name     | Eliminates redundant computation       |
| 4 | Function on filter column               | Use range filter on raw column               | Enables partition pruning              |
| 5 | Correlated subquery (O(n) per row)      | Window function with `QUALIFY`               | Single-pass set-based execution        |
| 6 | `SELECT DISTINCT` with no aggregation   | `GROUP BY` for explicit, extensible intent   | Clearer intent, easier to add metrics  |
| 7 | `SELECT *` inside CTEs                  | Thin CTE projections                         | Reduced memory and I/O                 |
| 8 | Two queries for two conditions          | Single scan with `FILTER (WHERE ...)`        | Cuts full-table scan from 2x to 1x     |

---

## Using EXPLAIN

DuckDB (and most SQL engines) expose execution plans via `EXPLAIN`:

```sql
EXPLAIN SELECT ...;
```

Key things to look for in the output:
- **Table Scans** — are you scanning the full table or a filtered subset?
- **Hash Join vs Nested Loop** — hash joins are generally more efficient for large tables
- **Projection** — does the plan show only the columns you selected?
- **Filters** — are your WHERE conditions applied early (pushed down)?

---

## Key Takeaway

> Write queries that are readable to humans AND efficient for machines.
> CTEs don't just help readability — they prevent redundant computation.
> Filter early. Select only what you need. Let the planner see simple predicates.

---

## File

[query_optimization.sql](query_optimization.sql)
