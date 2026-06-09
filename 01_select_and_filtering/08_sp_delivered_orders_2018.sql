-- Question: Which delivered orders from São Paulo customers were placed in 2018?
-- Technique: Multiple WHERE conditions combined with AND, date range filter, JOIN

SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    c.customer_city,
    c.customer_state
FROM olist_orders_dataset        AS o
JOIN olist_customers_dataset     AS c USING (customer_id)
WHERE o.order_status                = 'delivered'
  AND c.customer_state              = 'SP'
  AND o.order_purchase_timestamp   >= '2018-01-01'
  AND o.order_purchase_timestamp    < '2019-01-01'
ORDER BY o.order_purchase_timestamp DESC
LIMIT 20;
