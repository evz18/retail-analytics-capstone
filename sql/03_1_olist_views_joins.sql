-- -- OLIST: base orders view
-- CREATE OR ALTER VIEW dbo.vw_olist_orders AS
-- SELECT *
-- FROM
--     OPENROWSET(
--         BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/olist/orders.parquet',
--         FORMAT = 'PARQUET'
--     ) AS [result];

-- SELECT TOP 10*
-- FROM dbo.vw_olist_orders;

-- -- 1) CUSTOMERS
-- CREATE OR ALTER VIEW dbo.vw_olist_customers AS
-- SELECT *
-- FROM OPENROWSET(
--     BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/olist/customers.parquet',
--     FORMAT = 'PARQUET'
-- ) AS result;


-- -- 2) ORDER ITEMS
-- CREATE OR ALTER VIEW dbo.vw_olist_order_items AS
-- SELECT *
-- FROM OPENROWSET(
--     BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/olist/order_items.parquet',
--     FORMAT = 'PARQUET'
-- ) AS result;


-- -- 3) ORDER PAYMENTS
-- CREATE OR ALTER VIEW dbo.vw_olist_order_payments AS
-- SELECT *
-- FROM OPENROWSET(
--     BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/olist/order_payments.parquet',
--     FORMAT = 'PARQUET'
-- ) AS result;


-- -- 4) ORDER REVIEWS
-- CREATE OR ALTER VIEW dbo.vw_olist_order_reviews AS
-- SELECT *
-- FROM OPENROWSET(
--     BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/olist/order_reviews.parquet',
--     FORMAT = 'PARQUET'
-- ) AS result;

-- -- A) OLIST JOIN orders + customer reviews ! 
-- SELECT TOP 20
--     o.order_id,
--     o.customer_id,
--     o.order_status,
--     o.order_purchase_timestamp,
--     r.review_score
-- FROM dbo.vw_olist_orders o

-- LEFT JOIN dbo.vw_olist_order_reviews r  -- keep every order, even if no matching review
    -- ON o.order_id = r.order_id

-- B) Check whether orders can contain multiple items (yes, one-to-many)
-- SELECT TOP 10
--     order_id,
--     COUNT(*) AS num_items
-- FROM dbo.vw_olist_order_items
-- GROUP BY order_id
-- HAVING COUNT(*) > 1
-- ORDER BY num_items DESC;

-- C) Aggregate order items to 1 row per order
-- SELECT TOP 20
--     order_id,
--     COUNT(*) AS num_items,
--     ROUND(SUM(CAST(price AS DECIMAL(18,2))),2) AS item_total,
--     ROUND(SUM(CAST(freight_value AS DECIMAL(18,2))),2) AS freight_total -- shipping cost
-- FROM dbo.vw_olist_order_items
-- GROUP BY order_id
-- ORDER BY num_items DESC;

-- -- D) Same Aggregate order items but             CREATE VIEW !
-- CREATE OR ALTER VIEW dbo.vw_olist_items_by_order AS
-- SELECT 
--     order_id,
--     COUNT(*) AS num_items,
--     ROUND(SUM(CAST(price AS DECIMAL(18,2))),2) AS item_total,
--     ROUND(SUM(CAST(freight_value AS DECIMAL(18,2))),2) AS freight_total -- shipping cost
-- FROM dbo.vw_olist_order_items
-- GROUP BY order_id;

-- E) Combine order-level information
-- SELECT TOP 20
--     o.order_id,
--     o.customer_id,
--     o.order_status,
--     o.order_purchase_timestamp,

--     i.num_items,
--     i.item_total,
--     i.freight_total,

--     r.review_score
-- FROM dbo.vw_olist_orders o
-- LEFT JOIN dbo.vw_olist_items_by_order i 
--     ON o.order_id = i.order_id
-- LEFT JOIN dbo.vw_olist_order_reviews r
--     ON o.order_id = r.order_id;

-- F) Check whether an order can have multiple review rows (yes, 3 max)
-- SELECT TOP 20
--     order_id,
--     COUNT(*) AS num_reviews
-- FROM dbo.vw_olist_order_reviews
-- GROUP BY order_id
-- HAVING COUNT(*) > 1
-- ORDER BY num_reviews DESC;

-- G) Aggregate reviews to ONE ROW per order            CREATE VIEW
-- CREATE OR ALTER VIEW dbo.vw_olist_reviews_by_order AS

-- SELECT
--     order_id,
--     AVG(CAST(review_score AS DECIMAL(4,2))) AS avg_review_score,
--     COUNT(*) AS num_reviews
-- FROM dbo.vw_olist_order_reviews
-- GROUP BY order_id;

-- SELECT TOP 20 *
-- FROM dbo.vw_olist_reviews_by_order
-- ORDER BY num_reviews DESC;

 -- H) Combine orders + aggregated items + aggregated reviews       JOINED 3 VIEW TABLES
-- SELECT TOP 20
--     o.order_id,
--     o.customer_id,
--     o.order_status,
--     o.order_purchase_timestamp,

--     i.num_items,
--     i.item_total,
--     i.freight_total,

--     r.avg_review_score,
--     r.num_reviews

-- FROM dbo.vw_olist_orders o

-- LEFT JOIN dbo.vw_olist_items_by_order i
--     ON o.order_id = i.order_id

-- LEFT JOIN dbo.vw_olist_reviews_by_order r   -- note using new aggregated reviwew view table
--     ON o.order_id = r.order_id;

-- -- VERIFY no duplicates so 1 row = 1 unique order id 
-- SELECT
--     COUNT(*) AS total_rows,
--     COUNT(DISTINCT o.order_id) AS unique_orders
-- FROM dbo.vw_olist_orders o

-- LEFT JOIN dbo.vw_olist_items_by_order i
--     ON o.order_id = i.order_id

-- LEFT JOIN dbo.vw_olist_reviews_by_order r
--     ON o.order_id = r.order_id;

-- I) Base customers view               #CREATE CUSTOMERS VIEW table
-- CREATE OR ALTER VIEW dbo.vw_olist_customers AS
-- SELECT *
-- FROM OPENROWSET(
--     BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/olist/customers.parquet',
--     FORMAT = 'PARQUET'
-- ) AS result;

-- J) Add customer geography to order-level dataset    #TOTAL 4 VIEW TABLES JOINED 10 cols (o,c,i,r)
-- SELECT TOP 20
--     o.order_id,
--     o.customer_id,
--     o.order_status,
--     o.order_purchase_timestamp,

--     c.customer_city,
--     c.customer_state,

--     i.num_items,
--     i.item_total,
--     i.freight_total,

--     r.avg_review_score

-- FROM dbo.vw_olist_orders o

-- LEFT JOIN dbo.vw_olist_customers c
--     ON o.customer_id = c.customer_id

-- LEFT JOIN dbo.vw_olist_items_by_order i
--     ON o.order_id = i.order_id

-- LEFT JOIN dbo.vw_olist_reviews_by_order r
--     ON o.order_id = r.order_id;

-- -- K) Validate final JOIN is still one row per order (good, still 99441 unique)
-- SELECT
--     COUNT(*) AS total_rows,
--     COUNT(DISTINCT o.order_id) AS unique_orders
-- FROM dbo.vw_olist_orders o

-- LEFT JOIN dbo.vw_olist_customers c
--     ON o.customer_id = c.customer_id

-- LEFT JOIN dbo.vw_olist_items_by_order i
--     ON o.order_id = i.order_id

-- LEFT JOIN dbo.vw_olist_reviews_by_order r
--     ON o.order_id = r.order_id;

-- -- inspect Olist order types final time      (still all varchar!)
-- SELECT
--     COLUMN_NAME,
--     DATA_TYPE
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_NAME = 'vw_olist_orders';

-- L) Create curated Olist order-level view     #CREATE FINAL COMBINED VIEW TABLE w/correct dtypes !
CREATE OR ALTER VIEW dbo.vw_curated_olist AS
SELECT
    -- IDs / categories
    o.order_id,
    o.customer_id,
    o.order_status,

    --proper datetime types
    CAST(o.order_purchase_timestamp AS DATETIME2) AS order_purchase_timestamp,
    CAST(o.order_approved_at AS DATETIME2) AS order_approved_at,
    CAST(o.order_delivered_carrier_date AS DATETIME2) AS order_delivered_carrier_date,
    CAST(o.order_delivered_customer_date AS DATETIME2) AS order_delivered_customer_date,
    CAST(o.order_estimated_delivery_date AS DATETIME2) AS order_estimated_delivery_date,

    -- customer geography
    c.customer_city,
    c.customer_state,

    -- order-level item features
    i.num_items,
    i.item_total,
    i.freight_total,

    -- review
    r.avg_review_score,
    r.num_reviews

FROM dbo.vw_olist_orders o

LEFT JOIN dbo.vw_olist_customers c
    ON o.customer_id = c.customer_id

LEFT JOIN dbo.vw_olist_items_by_order i
    ON o.order_id = i.order_id

LEFT JOIN dbo.vw_olist_reviews_by_order r
    ON o.order_id = r.order_id;

SELECT TOP 10 *
FROM dbo.vw_curated_olist;
