# 01 — SELECT and Filtering

Foundational query patterns for selecting, filtering, and sorting data from the Olist dataset.

---

## Concepts Covered

| Concept         | Description                                               |
|-----------------|-----------------------------------------------------------|
| `SELECT`        | Column selection and aliasing                             |
| `WHERE`         | Row-level filtering with single and multiple conditions   |
| `AND` / `OR`    | Compound conditions                                       |
| `IN` / `NOT IN` | List-based filtering                                      |
| `BETWEEN`       | Range filtering for numeric and date columns              |
| `LIKE` / `ILIKE`| Case-sensitive and case-insensitive pattern matching      |
| `IS NULL`       | Identifying missing values                                |
| `DISTINCT`      | Removing duplicate rows                                   |
| `ORDER BY`      | Single and multi-column sorting                           |
| `LIMIT / OFFSET`| Result pagination                                         |

---

## Key Queries

| # | Business Question                                       | Technique           |
|---|---------------------------------------------------------|---------------------|
| 1 | What does an order record look like?                    | Column aliasing      |
| 2 | Which orders have been delivered?                       | WHERE equality       |
| 3 | Which orders were canceled or unavailable?              | WHERE with OR        |
| 4 | Which orders are in non-final states?                   | IN / NOT IN          |
| 5 | Which products weigh between 500g and 2kg?              | BETWEEN              |
| 6 | Which categories mention "eletro"?                      | ILIKE pattern match  |
| 7 | Which orders were never approved?                       | IS NULL              |
| 8 | How many distinct order statuses exist?                 | DISTINCT             |
| 9 | Which orders were placed in Q4 2017?                    | Date range filter    |
| 10| Which delivered orders came from São Paulo in 2018?     | Multi-condition JOIN |

---

## File

[select_and_filtering.sql](select_and_filtering.sql)
