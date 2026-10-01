-- This is auto-generated code
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/instacart/orders.parquet',
        FORMAT = 'PARQUET'
    ) AS [result]
    
-- verify order_id grain of 1 row per order
SELECT
    COUNT(*) AS total_rows,
    COUNT (DISTINCT order_id) as unique_orders
FROM
    OPENROWSET(
        BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/instacart/orders.parquet',
        FORMAT = 'PARQUET'
    ) AS orders;

-- 1)Create view of instacart orders                      instacart_orders View table
CREATE OR ALTER VIEW dbo.vw_instacart_orders AS
SELECT *
FROM
    OPENROWSET(
        BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/instacart/orders.parquet',
        FORMAT = 'PARQUET'
) AS orders; 
GO

-- 2)Create view of instacart aisles                      instacart_aisles View table
CREATE OR ALTER VIEW dbo.vw_instacart_aisles AS
SELECT *
FROM
    OPENROWSET(
        BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/instacart/aisles.parquet',
        FORMAT = 'PARQUET'
) AS aisles;
GO

-- 3)Create view of instacart departments                      instacart_departments View table
CREATE OR ALTER VIEW dbo.vw_instacart_departments AS
SELECT *
FROM
    OPENROWSET(
        BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/instacart/departments.parquet',
        FORMAT = 'PARQUET'
) AS departments;
GO

-- 4)Create view of instacart products                      instacart_products View table
CREATE OR ALTER VIEW dbo.vw_instacart_products AS
SELECT *
FROM
    OPENROWSET(
        BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/instacart/products.parquet',
        FORMAT = 'PARQUET'
) AS products;
GO

-- 5)Create view of products_prior                       products_prior View table
CREATE OR ALTER VIEW dbo.vw_instacart_order_products_prior AS
SELECT *
FROM
    OPENROWSET(
        BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/instacart/order_products_prior.parquet',
        FORMAT = 'PARQUET'
) AS order_products_prior;
GO          -- NOTE grain = 1 product per row, not order_id

-- 6)Create view of products_train                      products_train View table
CREATE OR ALTER VIEW dbo.vw_instacart_order_products_train AS
SELECT *
FROM
    OPENROWSET(
        BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/instacart/order_products_train.parquet',
        FORMAT = 'PARQUET'
) AS order_products_train;
GO

-- 7) Union All products_prior and products_train !     order_products_all table
CREATE OR ALTER VIEW dbo.vw_instacart_order_products_all AS
SELECT
    order_id,
    product_id,
    add_to_cart_order,
    reordered
FROM dbo.vw_instacart_order_products_prior

UNION ALL

SELECT
    order_id,
    product_id,
    add_to_cart_order,
    reordered
FROM dbo.vw_instacart_order_products_train;
GO

-- NOTE grain = 1 product per row, not order_id
SELECT TOP 10 *
FROM dbo.vw_instacart_order_products_prior;

-- NOTE connect order_products_prior to products using = product_id
SELECT TOP 10 *
FROM dbo.vw_instacart_products; -- connect further w/aisle + department_id!






-- >CURATED instacart view table                 curated_instacart view table!!
CREATE OR ALTER VIEW dbo.vw_curated_instacart AS

SELECT
    -- order-product information
    op.order_id,
    op.product_id,
    op.add_to_cart_order,
    op.reordered,

    -- order information
    o.user_id,
    o.order_number,
    o.order_dow,
    o.order_hour_of_day,
    o.days_since_prior_order,

    -- product information
    p.product_name,
    p.aisle_id,
    p.department_id,

    -- category information
    a.aisle,
    d.department

FROM dbo.vw_instacart_order_products_all op

LEFT JOIN dbo.vw_instacart_orders o
    ON op.order_id = o.order_id

LEFT JOIN dbo.vw_instacart_products p
    ON op.product_id = p.product_id

LEFT JOIN dbo.vw_instacart_aisles a
    ON p.aisle_id = a.aisle_id

LEFT JOIN dbo.vw_instacart_departments d
    ON p.department_id = d.department_id;

-- 14 columns 
SELECT TOP 5 *
FROM dbo.vw_curated_instacart;

-- verify 33,819,106 rows match
SELECT
    COUNT(*) AS curated_rows
FROM dbo.vw_curated_instacart;
SELECT
    COUNT(*) AS original_rows
FROM dbo.vw_instacart_order_products_all;




