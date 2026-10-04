SELECT DB_NAME() AS current_database;

-- create view
CREATE VIEW dbo.vw_us_ecommerce AS
SELECT *
FROM OPENROWSET(
    BULK
    'https://evzomdssa.dfs.core.windows.net/retail-capstone/processed/us-ecommerce/us_ecommerce_2020.parquet',
    FORMAT = 'PARQUET'
)AS result;

-- top 10
SELECT TOP 10 *
FROM dbo.vw_us_ecommerce;


-- Inspect current column data types (currently all varchar)
SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'vw_us_ecommerce';

-- CREATE curated US E-Commerce view with analytics-ready data types !! 
CREATE OR ALTER VIEW dbo.vw_curated_us_ecommerce AS
SELECT
    CAST(order_date AS DATE) AS order_date,
    CAST(row_id AS INT) AS row_id,

    order_id,
    ship_mode,
    customer_id,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,

    CAST(sales AS DECIMAL(18,2)) AS sales,
    CAST(quantity AS INT) AS quantity,
    CAST(discount AS DECIMAL(10,4)) AS discount,
    CAST(profit AS DECIMAL(18,2)) AS profit

FROM dbo.vw_us_ecommerce;

SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'vw_curated_us_ecommerce';

