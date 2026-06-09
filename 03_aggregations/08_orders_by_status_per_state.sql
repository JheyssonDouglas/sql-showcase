-- Question: How are orders distributed by status within each customer state?
-- Technique: Conditional aggregation with FILTER (WHERE ...) — pivot-style

SELECT
    c.customer_state,
    COUNT(*)                                                      AS total_orders,
    COUNT(*) FILTER (WHERE o.order_status = 'delivered')          AS delivered,
    COUNT(*) FILTER (WHERE o.order_status = 'canceled')           AS canceled,
    COUNT(*) FILTER (WHERE o.order_status = 'shipped')            AS shipped,
    COUNT(*) FILTER (WHERE o.order_status = 'processing')         AS processing
FROM olist_customers_dataset     AS c
INNER JOIN olist_orders_dataset   AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;
