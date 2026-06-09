-- Question: What is month-over-month revenue change in absolute and percentage terms?
-- Technique: LAG() to access the previous row's value

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)  AS order_month,
        ROUND(SUM(oi.price), 2)                          AS revenue
    FROM olist_orders_dataset            AS o
    INNER JOIN olist_order_items_dataset  AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
)
SELECT
    order_month,
    revenue,
    LAG(revenue) OVER (ORDER BY order_month)                                AS prev_month,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY order_month), 2)            AS absolute_change,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_month))
        / NULLIF(LAG(revenue) OVER (ORDER BY order_month), 0) * 100
    , 2)                                                                     AS pct_change
FROM monthly_revenue
ORDER BY order_month;
