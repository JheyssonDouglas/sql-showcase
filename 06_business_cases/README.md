# 06 — Business Cases

Real-world analytical queries answering the KPIs a Data Analyst or Analytics Engineer would be asked to build.

---

## Cases

### Revenue Analysis
| File | Question |
|------|----------|
| [01_monthly_revenue_trend.sql](01_monthly_revenue_trend.sql) | What is the monthly revenue and order volume trend? |
| [02_yoy_revenue_growth.sql](02_yoy_revenue_growth.sql) | What is the year-over-year revenue growth rate? |
| [03_top_states_market_share.sql](03_top_states_market_share.sql) | Which states hold the largest market share? |

### Customer Analysis
| File | Question |
|------|----------|
| [04_monthly_customer_acquisition.sql](04_monthly_customer_acquisition.sql) | How many new customers were acquired each month? |
| [05_repeat_customer_rate.sql](05_repeat_customer_rate.sql) | What percentage of customers make a repeat purchase? |
| [06_customer_ltv_top20.sql](06_customer_ltv_top20.sql) | Who are the top 20 customers by lifetime revenue? |

### Seller & Delivery
| File | Question |
|------|----------|
| [07_seller_performance_scorecard.sql](07_seller_performance_scorecard.sql) | How do sellers compare across all key metrics? |
| [08_delivery_ontime_by_state.sql](08_delivery_ontime_by_state.sql) | Which states have the best on-time delivery rate? |
| [09_late_orders_analysis.sql](09_late_orders_analysis.sql) | How late are delayed orders on average, per state? |

### Customer Segmentation
| File | Question |
|------|----------|
| [10_rfm_segmentation.sql](10_rfm_segmentation.sql) | How can customers be segmented using the RFM model? |

---

## Skills Demonstrated

- Multi-step CTE chains
- Window functions in a business context (`LAG`, `RANK`, `NTILE`)
- Conditional aggregation with `FILTER (WHERE ...)`
- Date arithmetic for SLA and delivery analysis
- `NULLIF` for safe division
- RFM: Recency, Frequency, Monetary segmentation model
