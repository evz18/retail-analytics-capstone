-- A) Check if orders can have multiple payment rows!
-- SELECT TOP 20
--     order_id, --suspicious key
--     COUNT(*) AS num_payments
-- FROM dbo.vw_olist_order_payments    --suspicious table
-- GROUP BY order_id
-- HAVING COUNT(*) > 1     -- RESULT = one order = multiple payments/rows must fix
-- ORDER BY num_payments DESC;

-- How many different payment types and number of each
-- SELECT 
--     payment_type,
--     COUNT(*) AS num_payments
-- FROM dbo.vw_olist_order_payments
-- GROUP BY payment_type
-- ORDER BY num_payments DESC;     -- result credit 79k, bolet 19k, etc.

--> Can single order use more than one payment type
-- SELECT
--     order_id,
--     COUNT (DISTINCT payment_type) AS diff_payments      --distinct count every order's DIFFERENT payment types! 
-- FROM dbo.vw_olist_order_payments
-- GROUP BY order_id   -- group by each order
-- HAVING COUNT(DISTINCT payment_type) >1
-- ORDER BY diff_payments DESC; 

--> Now subquery how many count orders have distinct payment types --(use aggregate diff_payments as NEW grouping!)
-- SELECT
--     diff_payments,
--     COUNT(*) AS num_orders
-- FROM (                      -- original grouping
--     SELECT
--         order_id,
--         COUNT(DISTINCT payment_type) AS diff_payments
--     FROM dbo.vw_olist_order_payments
--     GROUP BY order_id
-- ) AS payment_counts         -- temporary subquery result table

-- GROUP BY diff_payments
-- ORDER BY diff_payments DESC;

-- B) Aggregate payments to one row per order                   CREATE NEW VIEW payments_by_order
-- CREATE OR ALTER VIEW dbo.vw_olist_payments_by_order AS
-- SELECT
--     order_id,
--     COUNT(*) AS num_payment_records, -- count rows that order originally had    
--     SUM(CAST(payment_value AS DECIMAL(18,2))) AS total_payment_value, --total payment for 1 order
--     MAX(CAST(payment_installments AS INT)) AS max_installments  -- find max installments number
-- FROM dbo.vw_olist_order_payments
-- GROUP BY order_id;

-- C) Update curated Olist view with payment features           --UPDATED curated view 4->6tables(o,c,i,p,pr,r)!
-- CREATE OR ALTER VIEW dbo.vw_curated_olist AS
-- SELECT
--     -- ORDER INFO
--     o.order_id,
--     o.customer_id,
--     o.order_status,

--     -- convert timestamp strings to actual datetime values
--     CAST(o.order_purchase_timestamp AS DATETIME2) AS order_purchase_timestamp,
--     CAST(o.order_approved_at AS DATETIME2) AS order_approved_at,
--     CAST(o.order_delivered_carrier_date AS DATETIME2) AS order_delivered_carrier_date,
--     CAST(o.order_delivered_customer_date AS DATETIME2) AS order_delivered_customer_date,
--     CAST(o.order_estimated_delivery_date AS DATETIME2) AS order_estimated_delivery_date,

--     -- CUSTOMER LOCATION
--     c.customer_city,
--     c.customer_state,

--     -- ORDER ITEM FEATURES
--     i.num_items,
--     i.item_total,
--     i.freight_total,

--     -- PRODUCT FEATURES
--     pr.num_unique_products,
--     pr.total_product_weight_g,

--     -- PAYMENT FEATURES
--     p.num_payment_records,
--     p.total_payment_value,
--     p.max_installments,

--     -- REVIEW FEATURES
--     r.avg_review_score,
--     r.num_reviews

-- FROM dbo.vw_olist_orders o

-- -- customer information
-- LEFT JOIN dbo.vw_olist_customers c
--     ON o.customer_id = c.customer_id

-- -- item data already aggregated to one row per order
-- LEFT JOIN dbo.vw_olist_items_by_order i
--     ON o.order_id = i.order_id

-- -- payment data already aggregated to one row per order
-- LEFT JOIN dbo.vw_olist_payments_by_order p
--     ON o.order_id = p.order_id

-- -- product data already aggregated to one row per order
-- LEFT JOIN dbo.vw_olist_products_by_order pr
--     ON o.order_id = pr.order_id

-- -- review data already aggregated to one row per order
-- LEFT JOIN dbo.vw_olist_reviews_by_order r
--     ON o.order_id = r.order_id;

-- SELECT TOP 10 *
-- FROM dbo.vw_curated_olist;

-- C+D) Create base view for Olist products
-- CREATE OR ALTER VIEW dbo.vw_olist_products AS
-- SELECT *
-- FROM OPENROWSET(
--     BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/olist/products.parquet',
--     FORMAT = 'PARQUET'
-- ) AS result;

-- -- E) Inspect product columns
-- SELECT
--     COLUMN_NAME,
--     DATA_TYPE
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_NAME = 'vw_olist_products';

-- -- F) Aggregate product information to ONE ROW PER ORDER            NEW VIEW products_by_order
-- -- F) Aggregate product information to ONE ROW PER ORDER
-- CREATE OR ALTER VIEW dbo.vw_olist_products_by_order AS

-- SELECT
--     oi.order_id,

--     -- number of different products in the order
--     COUNT(DISTINCT oi.product_id) AS num_unique_products,

--     -- total product weight associated with the order
--     SUM(CAST(p.product_weight_g AS DECIMAL(18,2))) AS total_product_weight_g

-- FROM dbo.vw_olist_order_items oi

-- -- connect each order item to its product information
-- LEFT JOIN dbo.vw_olist_products p
--     ON oi.product_id = p.product_id

-- -- aggregate multiple product rows into one row per order
-- GROUP BY oi.order_id;

-- G) Create base view for Olist sellers
-- CREATE OR ALTER VIEW dbo.vw_olist_sellers AS

-- SELECT *
-- FROM OPENROWSET(
--     BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/olist/sellers.parquet',
--     FORMAT = 'PARQUET'
-- ) AS result;

-- -- H) Aggregate seller information to ONE ROW PER ORDER      CREATE VIEW sellers_by_order
-- CREATE OR ALTER VIEW dbo.vw_olist_sellers_by_order AS
-- SELECT
--     order_id,
--     -- number of different sellers involved in the order
--     COUNT(DISTINCT seller_id) AS num_sellers
-- FROM dbo.vw_olist_order_items

-- -- aggregate multiple item/seller rows into one row per order
-- GROUP BY order_id;

-- Z) Update curated Olist view with payment features      --UPDATED 24cols curated view 7tables(o,c,i,p,pr,s,r)!
CREATE OR ALTER VIEW dbo.vw_curated_olist AS
SELECT
    -- ORDER INFO
    o.order_id,
    o.customer_id,
    o.order_status,

    -- convert timestamp strings to actual datetime values
    CAST(o.order_purchase_timestamp AS DATETIME2) AS order_purchase_timestamp,
    CAST(o.order_approved_at AS DATETIME2) AS order_approved_at,
    CAST(o.order_delivered_carrier_date AS DATETIME2) AS order_delivered_carrier_date,
    CAST(o.order_delivered_customer_date AS DATETIME2) AS order_delivered_customer_date,
    CAST(o.order_estimated_delivery_date AS DATETIME2) AS order_estimated_delivery_date,

    -- DERIVED DELIVERY FEATURES

        -- actual number of days from purchase to customer delivery
    DATEDIFF(
        DAY,
        CAST(o.order_purchase_timestamp AS DATETIME2),
        CAST(o.order_delivered_customer_date AS DATETIME2)
    ) AS delivery_days,

        -- number of days originally estimated for delivery
    DATEDIFF(
        DAY,
        CAST(o.order_purchase_timestamp AS DATETIME2),
        CAST(o.order_estimated_delivery_date AS DATETIME2)
    ) AS estimated_delivery_days,

        -- 1 = delivered after estimated delivery date      late_delivery binary variable !
    CASE
        WHEN CAST(o.order_delivered_customer_date AS DATETIME2)
            > CAST(o.order_estimated_delivery_date AS DATETIME2)
        THEN 1
        ELSE 0
    END AS late_delivery,

        -- month order was purchased
    MONTH(CAST(o.order_purchase_timestamp AS DATETIME2)) AS purchase_month,

    -- CUSTOMER LOCATION
    c.customer_city,
    c.customer_state,

    -- ORDER ITEM FEATURES
    i.num_items,
    i.item_total,
    i.freight_total,

    -- PRODUCT FEATURES
    pr.num_unique_products,
    pr.total_product_weight_g,

    -- PAYMENT FEATURES
    p.num_payment_records,
    p.total_payment_value,
    p.max_installments,
    
    -- SELLER FEATURES
    s.num_sellers,

    -- REVIEW FEATURES
    r.avg_review_score,
    r.num_reviews,    
    CASE
        WHEN r.avg_review_score >= 4 THEN 1
        ELSE 0
    END AS positive_review                  --create positive_review binary variable!

FROM dbo.vw_olist_orders o

-- customer information
LEFT JOIN dbo.vw_olist_customers c
    ON o.customer_id = c.customer_id

-- item data already aggregated to one row per order
LEFT JOIN dbo.vw_olist_items_by_order i
    ON o.order_id = i.order_id

-- payment data already aggregated to one row per order
LEFT JOIN dbo.vw_olist_payments_by_order p
    ON o.order_id = p.order_id

-- product data already aggregated to one row per order
LEFT JOIN dbo.vw_olist_products_by_order pr
    ON o.order_id = pr.order_id

-- seller data already aggregated to one row per order
LEFT JOIN dbo.vw_olist_sellers_by_order s
    ON o.order_id = s.order_id

-- review data already aggregated to one row per order
LEFT JOIN dbo.vw_olist_reviews_by_order r
    ON o.order_id = r.order_id;

SELECT TOP 10 *
FROM dbo.vw_curated_olist;

-- I) Validate final curated dataset grain (yes 99441 unique)
-- total rows should equal unique orders
-- SELECT
--     COUNT(*) AS total_rows,
--     COUNT(DISTINCT order_id) AS unique_orders
-- FROM dbo.vw_curated_olist;
