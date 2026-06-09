# 06 — Business Cases

Real-world analytical use cases answering the business questions a Data Analyst or Analytics Engineer would face on the job.

---

## Cases

### Case 1 — Revenue Analysis
Understanding how the business generates revenue over time.

| Query | Question                                           |
|-------|----------------------------------------------------|
| 1a    | What is monthly revenue and order volume?          |
| 1b    | What is the year-over-year growth rate?            |
| 1c    | Which states hold the largest market share?        |

---

### Case 2 — Customer Analysis
Understanding the customer base and its value over time.

| Query | Question                                              |
|-------|-------------------------------------------------------|
| 2a    | How many new customers were acquired each month?      |
| 2b    | What percentage of customers make a repeat purchase?  |
| 2c    | Who are the highest lifetime value customers?         |

---

### Case 3 — Seller Performance Scorecard
A single query that summarizes each seller across all key dimensions.

| Metric            | Description                                |
|-------------------|--------------------------------------------|
| Total orders      | Volume handled by the seller               |
| Total revenue     | Product revenue generated                  |
| Avg review score  | Customer satisfaction rating               |
| Avg delivery days | How fast the seller ships                  |
| On-time %         | Share of orders delivered before ETA        |

---

### Case 4 — Delivery Performance
Evaluating logistics performance by customer state.

| Query | Question                                                |
|-------|---------------------------------------------------------|
| 4a    | Which states have the highest on-time delivery rate?    |
| 4b    | Which states have the worst average delay in late orders?|

---

### Case 5 — RFM Segmentation
Classifying customers using the **Recency–Frequency–Monetary** framework.

| Segment             | Profile                                              |
|---------------------|------------------------------------------------------|
| Champions           | Bought recently, buy often, high spend               |
| Loyal Customers     | Buy regularly, good spend                            |
| Promising           | Recent buyers with low frequency yet                 |
| Potential Loyalists | Good recency, moderate frequency                     |
| At Risk             | High frequency but haven't bought recently           |
| Need Attention      | Mid-range recency and frequency, declining           |
| Lost                | Haven't bought in a long time, low frequency         |

---

## Skills Demonstrated

- Multi-step CTE chains
- Window functions in a business context
- Conditional aggregation with `FILTER (WHERE ...)`
- Date arithmetic for SLA analysis
- `NTILE` for score bucketing
- `NULLIF` for safe division
- Real KPIs: LTV, repeat rate, on-time delivery, YoY growth, RFM

---

## File

[business_cases.sql](business_cases.sql)
