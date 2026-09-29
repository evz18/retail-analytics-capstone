-- A) Customer satisfaction by delivery status
SELECT 
    late_delivery,
    COUNT(*) AS num_orders,
    ROUND(AVG(avg_review_score),2) AS avg_review_score,
    ROUND(AVG(CAST(positive_review AS DECIMAL(10,4)))*100,2)
    AS positive_review_count
FROM dbo.vw_curated_olist

-- only include orders with a review
WHERE avg_review_score IS NOT NULL
GROUP BY late_delivery
ORDER BY late_delivery;
-- Finding: Late deliveries show substantially lower customer satisfaction.
-- Positive review rate falls from 80.63% to 34.56% for late orders.


-- B) Customer satisfaction by order size
SELECT
    CASE
        WHEN num_items = 1 THEN '1 item'
        WHEN num_items BETWEEN 2 AND 3 THEN '2-3 items'
        WHEN num_items BETWEEN 4 AND 5 THEN '4-5 items'
        ELSE '6+ items'
    END AS order_size,
    COUNT(*) AS num_orders,

    -- average customer review score
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,

    -- percentage of orders with a positive review
    ROUND(
        AVG(CAST(positive_review AS DECIMAL(10,4))) * 100,
        2
    ) AS positive_review_pct

FROM dbo.vw_curated_olist

-- only orders with review information
WHERE avg_review_score IS NOT NULL

GROUP BY
    CASE
        WHEN num_items = 1 THEN '1 item'
        WHEN num_items BETWEEN 2 AND 3 THEN '2-3 items'
        WHEN num_items BETWEEN 4 AND 5 THEN '4-5 items'
        ELSE '6+ items'
    END
-- Finding: Customer satisfaction generally decreased as order size increased.
-- Positive review rate decreased from 79.16% for 1-item orders,
-- to 63.60% for 2-3 items, 56.35% for 4-5 items,
-- and 23.48% for orders with 6+ items.
-- Larger/more complex orders were associated with lower customer satisfaction.


-- C) Satisfaction by BOTH order size and delivery status
SELECT
    CASE -- create bins of item order sizes
        WHEN num_items = 1 THEN '1 item'
        WHEN num_items BETWEEN 2 AND 3 THEN '2-3 items'
        WHEN num_items BETWEEN 4 AND 5 THEN '4-5 items'
        ELSE '6+ items'
    END AS order_size,

    late_delivery,

    -- number of orders in each combination
    COUNT(*) AS num_orders,
    -- average review score
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,
    -- percent of reviews that are positive
    ROUND(
        AVG(CAST(positive_review AS DECIMAL(10,4))) * 100,
        2
    ) AS positive_review_pct
FROM dbo.vw_curated_olist
WHERE avg_review_score IS NOT NULL

GROUP BY
    CASE
        WHEN num_items = 1 THEN '1 item'
        WHEN num_items BETWEEN 2 AND 3 THEN '2-3 items'
        WHEN num_items BETWEEN 4 AND 5 THEN '4-5 items'
        ELSE '6+ items'
    END,
    late_delivery
ORDER BY order_size, late_delivery; -- SORTS rows each item size with each binary late_delivery!
-- C) Finding: Order size remained associated with satisfaction even after
-- separating orders by delivery status. 
--      Among on-time orders, positive review rates 
--          decreased from 83.01% for 1-item orders to 65.70% for 2-3 items,
--          58.01% for 4-5 items, and 23.46% for 6+ items.
--      Late delivery was also associated with substantially lower satisfaction
--          within the 1-item, 2-3 item, and 4-5 item groups.
--          The 6+ late group contained only 16 orders, so that comparison is unstable.

-- D) Customer satisfaction by payment installments
SELECT
    CASE
        WHEN max_installments = 1 THEN '1 installment'
        WHEN max_installments BETWEEN 2 AND 5 THEN '2-5 installments'
        WHEN max_installments BETWEEN 6 AND 10 THEN '6-10 installments'
        ELSE '11+ installments'
    END AS installment_group,
    COUNT(*) AS num_orders,
    -- average customer review
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,
    -- percentage of positive reviews
    ROUND(
        AVG(CAST(positive_review AS DECIMAL(10,4))) * 100,
        2
    ) AS positive_review_pct
FROM dbo.vw_curated_olist
WHERE avg_review_score IS NOT NULL

GROUP BY
    CASE
        WHEN max_installments = 1 THEN '1 installment'
        WHEN max_installments BETWEEN 2 AND 5 THEN '2-5 installments'
        WHEN max_installments BETWEEN 6 AND 10 THEN '6-10 installments'
        ELSE '11+ installments'
    END
ORDER BY num_orders DESC;
-- Finding: Customer satisfaction decreased slightly as the number of payment installments increased. Positive review rates declined from
--      78.05% for 1 installment to 72.49% for 11+ installments.
-- This relationship was much weaker than the patterns observed for
-- delivery status and order size.
-- Note: the 11+ installment group contained only 338 orders.
