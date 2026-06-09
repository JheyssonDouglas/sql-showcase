-- Question: What is the 3-day rolling average of daily orders (to smooth out noise)?
-- Technique: AVG() OVER with ROWS BETWEEN 2 PRECEDING AND CURRENT ROW

WITH daily_orders AS (
    SELECT
        DATE_TRUNC('day', order_purchase_timestamp) AS order_day,
        COUNT(*)                                     AS daily_count
    FROM olist_orders_dataset
    WHERE order_status = 'delivered'
    GROUP BY order_day
)
SELECT
    order_day,
    daily_count,
    ROUND(AVG(daily_count) OVER (
        ORDER BY order_day
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 1)                                AS rolling_3day_avg
FROM daily_orders
ORDER BY order_day;
