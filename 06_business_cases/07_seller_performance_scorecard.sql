-- Question: How do sellers compare across revenue, review score, and delivery performance?
-- Case: Seller Performance — single scorecard query combining all key metrics

WITH seller_metrics AS (
    SELECT
        s.seller_id,
        s.seller_city,
        s.seller_state,
        COUNT(DISTINCT oi.order_id)                                    AS total_orders,
        ROUND(SUM(oi.price), 2)                                        AS total_revenue,
        ROUND(AVG(oi.price), 2)                                        AS avg_item_price,
        ROUND(AVG(r.review_score), 2)                                  AS avg_review_score,
        ROUND(AVG(
            DATEDIFF('day',
                o.order_purchase_timestamp,
                o.order_delivered_customer_date)
        ), 1)                                                          AS avg_delivery_days,
        COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date <= o.order_estimated_delivery_date
              AND o.order_delivered_customer_date IS NOT NULL
        )                                                              AS on_time_deliveries,
        COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date IS NOT NULL
        )                                                              AS total_delivered
    FROM olist_sellers_dataset              AS s
    INNER JOIN olist_order_items_dataset    AS oi ON s.seller_id  = oi.seller_id
    INNER JOIN olist_orders_dataset         AS o  ON oi.order_id  = o.order_id
    LEFT  JOIN olist_order_reviews_dataset  AS r  ON o.order_id   = r.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY s.seller_id, s.seller_city, s.seller_state
    HAVING COUNT(DISTINCT oi.order_id) >= 10
)
SELECT
    seller_id,
    seller_city,
    seller_state,
    total_orders,
    total_revenue,
    avg_item_price,
    avg_review_score,
    avg_delivery_days,
    ROUND(on_time_deliveries * 100.0 / NULLIF(total_delivered, 0), 1) AS on_time_pct
FROM seller_metrics
ORDER BY total_revenue DESC
LIMIT 20;
