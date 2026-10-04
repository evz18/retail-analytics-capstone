-- A) Reorder Rate by Department
SELECT 
    department,
    COUNT (*) AS num_products_ordered, -- each row = 1 product
    ROUND( -- average binary to get percentage
        AVG( CAST(reordered AS DECIMAL(10,4)) ) * 100,
        2
    ) AS reordered_rate_pct
FROM dbo.vw_curated_instacart
GROUP BY department
ORDER BY reordered_rate_pct DESC;
-- Results = Highest reorder rates in dairy/eggs (67.02%), 
-- beverages (65.37%), and produce (65.05%).
-- Produce had the highest order volume among these departments,
-- with approximately 9.9 million product-order records.


-- B) Reorder rate by cart position
SELECT  
    CASE -- cart position by bins
        WHEN add_to_cart_order = 1 THEN '1st'
        WHEN add_to_cart_order BETWEEN 2 AND 5 THEN '2-5'
        WHEN add_to_cart_order BETWEEN 6 AND 10 THEN '6-10'
        ELSE '11+'
    END AS cart_position,
    COUNT(*) AS num_products_ordered, 
    ROUND(
        AVG (CAST(reordered AS DECIMAL (10,4))) * 100,
        2
    ) AS reordered_rate_pct
FROM dbo.vw_curated_instacart
GROUP BY 
    CASE    
        WHEN add_to_cart_order = 1 THEN '1st'
        WHEN add_to_cart_order BETWEEN 2 AND 5 THEN '2-5'
        WHEN add_to_cart_order BETWEEN 6 AND 10 THEN '6-10'
        ELSE '11+'
    END
ORDER BY MIN(add_to_cart_order); -- sort earlier cart positions
--Results: Reorder rate decreased as products were added later to the cart.
-- Products added first had a 67.93% reorder rate, compared with 64.95%
-- for positions 2-5, 57.75% for positions 6-10, and 50.10% for 11+.
-- Earlier cart position was thus associated with stronger repeat purchasing.

-- C) Reorder rate by customer's order number
-- "As a customer makes more orders, does more of their basket consist of previously purchased products"
SELECT
    CASE
        WHEN order_number BETWEEN 1 AND 5 THEN '1-5'
        WHEN order_number BETWEEN 6 AND 10 THEN '6-10'
        WHEN order_number BETWEEN 11 AND 20 THEN '11-20'
        ELSE '21+'
    END AS customer_order_number,
    COUNT(*) AS num_products_ordered,
    ROUND(
        AVG(CAST(reordered AS DECIMAL(10,4))) * 100,
        2
    ) AS reorder_rate_pct
FROM dbo.vw_curated_instacart

GROUP BY
    CASE
        WHEN order_number BETWEEN 1 AND 5 THEN '1-5'
        WHEN order_number BETWEEN 6 AND 10 THEN '6-10'
        WHEN order_number BETWEEN 11 AND 20 THEN '11-20'
        ELSE '21+'
    END
ORDER BY MIN(order_number);
-- Results: Reorder rate increased substantially with customer order history.
-- Products in customers' first 1-5 orders had a 31.58% reorder rate,
-- increasing to 58.75% for orders 6-10, 69.23% for orders 11-20,
-- and 78.86% for orders 21+.

-- D) Reorder rate by days since prior order
    -- Convert days_since_prior_order from VARCHAR to numeric once
WITH typed_data AS ( --CTE
    SELECT
        *,
        CAST(days_since_prior_order AS DECIMAL(10,2)) AS days_since_prior
    FROM dbo.vw_curated_instacart
)
SELECT
    CASE
        WHEN days_since_prior <= 7 THEN '0-7 days'
        WHEN days_since_prior <= 14 THEN '8-14 days'
        WHEN days_since_prior <= 21 THEN '15-21 days'
        ELSE '22+ days'
    END AS days_since_prior_group,
    COUNT(*) AS num_products_ordered,
    ROUND(
        AVG(CAST(reordered AS DECIMAL(10,4))) * 100,
        2
    ) AS reorder_rate_pct

FROM typed_data
-- First orders have no prior order
WHERE days_since_prior IS NOT NULL

GROUP BY
    CASE
        WHEN days_since_prior <= 7 THEN '0-7 days'
        WHEN days_since_prior <= 14 THEN '8-14 days'
        WHEN days_since_prior <= 21 THEN '15-21 days'
        ELSE '22+ days'
    END
ORDER BY MIN(days_since_prior);
-- Results: Reorder rate decreased as time since the previous order
-- increased, from 67.47% within 0-7 days to 49.28% after 22+ days.
-- This suggests that more frequent orders contained a greater proportion
-- of products the customer had purchased previously.






