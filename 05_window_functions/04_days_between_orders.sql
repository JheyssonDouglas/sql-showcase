-- Question: How many days pass between each customer's consecutive orders?
-- Technique: LEAD() to access the next row's value within a partition

SELECT
    customer_id,
    order_id,
    order_purchase_timestamp,
    LEAD(order_purchase_timestamp) OVER (
        PARTITION BY customer_id
        ORDER BY order_purchase_timestamp
    )                                                  AS next_order_timestamp,
    DATEDIFF('day',
        order_purchase_timestamp,
        LEAD(order_purchase_timestamp) OVER (
            PARTITION BY customer_id
            ORDER BY order_purchase_timestamp
        )
    )                                                  AS days_to_next_order
FROM olist_orders_dataset
ORDER BY customer_id, order_purchase_timestamp
LIMIT 30;
