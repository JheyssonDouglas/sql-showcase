-- Question: How can customers be segmented using the RFM model?
-- Case: RFM Segmentation — Recency, Frequency, Monetary

WITH rfm_base AS (
    SELECT
        c.customer_id,
        DATEDIFF('day',
            MAX(o.order_purchase_timestamp),
            (SELECT MAX(order_purchase_timestamp) FROM olist_orders_dataset)
        )                                     AS recency_days,
        COUNT(DISTINCT o.order_id)            AS frequency,
        ROUND(SUM(oi.price), 2)               AS monetary
    FROM olist_customers_dataset         AS c
    INNER JOIN olist_orders_dataset      AS o  ON c.customer_id = o.customer_id
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id    = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days ASC)  AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)      AS m_score
    FROM rfm_base
),
rfm_segments AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        r_score, f_score, m_score,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3                   THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2                   THEN 'Promising'
            WHEN r_score >= 3 AND f_score <= 2                   THEN 'Potential Loyalists'
            WHEN r_score <= 2 AND f_score >= 4                   THEN 'At Risk'
            WHEN r_score <= 2 AND f_score >= 2                   THEN 'Need Attention'
            ELSE                                                       'Lost'
        END AS segment
    FROM rfm_scores
)
SELECT
    segment,
    COUNT(*)                       AS customer_count,
    ROUND(AVG(recency_days), 1)    AS avg_recency_days,
    ROUND(AVG(frequency), 2)       AS avg_frequency,
    ROUND(AVG(monetary), 2)        AS avg_monetary,
    ROUND(SUM(monetary), 2)        AS segment_revenue
FROM rfm_segments
GROUP BY segment
ORDER BY segment_revenue DESC;
