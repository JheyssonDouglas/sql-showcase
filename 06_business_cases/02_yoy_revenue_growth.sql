-- Question: What is the year-over-year revenue growth rate?
-- Case: Revenue Analysis (1b)

WITH yearly_revenue AS (
    SELECT
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
        ROUND(SUM(oi.price), 2)                        AS revenue
    FROM olist_orders_dataset            AS o
    INNER JOIN olist_order_items_dataset  AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_year
)
SELECT
    order_year,
    revenue,
    LAG(revenue) OVER (ORDER BY order_year)           AS prev_year_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_year))
        / NULLIF(LAG(revenue) OVER (ORDER BY order_year), 0) * 100
    , 2)                                               AS yoy_growth_pct
FROM yearly_revenue
ORDER BY order_year;
