-- 1) Amazon reviews
CREATE OR ALTER VIEW dbo.vw_amazon_reviews AS
SELECT *
FROM OPENROWSET(
    BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/raw/amazon/electronics_500k.parquet',
    FORMAT = 'PARQUET'
) AS reviews;
GO


-- 2) Amazon product metadata
CREATE OR ALTER VIEW dbo.vw_amazon_metadata AS
SELECT *
FROM OPENROWSET(
    BULK 'https://evzomdssa.dfs.core.windows.net/retail-capstone/raw/amazon/meta_electronics_500k.parquet',
    FORMAT = 'PARQUET'
) AS metadata;
GO

SELECT TOP 10 *
FROM dbo.vw_amazon_reviews;
-- each line = 1 review (+ rating, image, user_id, etc.)

SELECT TOP 10 *
FROM dbo.vw_amazon_metadata;
-- each line = 1 product (category, avg rating, price, etc)
-- CONFIRM whether parent_asin is unique
SELECT 
    COUNT (*) AS total_rows,
    COUNT(DISTINCT parent_asin) AS unique_products
FROM dbo.vw_amazon_metadata;
    -- Result = 500k vs 499,999
-- Why 1 different
SELECT -- (if multiple rows for one product/parent_asin)
    parent_asin,
    COUNT(*) AS row_count
FROM dbo.vw_amazon_metadata
WHERE parent_asin IS NOT NULL
GROUP BY parent_asin
HAVING COUNT(*) > 1;
    -- Result b014k9dj72 = 2 rows
SELECT *
FROM dbo.vw_amazon_metadata
WHERE parent_asin = 'b014k9dj72'
    -- RESULT = one row lowercase 'b', other uppercase 'B'

-- *** AMAZON GRAIN -> 1 product per row = help predict product popularity *** 
--A) Aggregate reviews table to product-level
CREATE OR ALTER VIEW dbo.vw_amazon_reviews_by_product AS
SELECT
    UPPER(parent_asin) AS parent_asin,
    -- num of review records in all 500k
    COUNT(*) AS num_reviews_sample,
    --total helpful votes received across those reviews!
    SUM(CAST(helpful_vote AS BIGINT)) AS total_helpful_votes
FROM dbo.vw_amazon_reviews
WHERE parent_asin IS NOT NULL
GROUP BY UPPER(parent_asin)
GO
-- now aggregated 177,727 products (can have multiple reviews per product)
SELECT COUNT(*) AS num_rows
FROM dbo.vw_amazon_reviews_by_product;

--B)Aggregate metadata table to product-level
CREATE OR ALTER VIEW dbo.vw_amazon_metadata_clean AS
SELECT DISTINCT
    UPPER(parent_asin) AS parent_asin, --fix duplicate asin row
    main_category,
    title,
    average_rating,
    rating_number,
    price
FROM dbo.vw_amazon_metadata
WHERE parent_asin IS NOT NULL;
GO
-- now cleaned 499,999 rows
SELECT COUNT(*) as num_products, 
COUNT(DISTINCT parent_asin) AS n_unique
FROM dbo.vw_amazon_metadata_clean;

--C) BUILD FINAL CURATED AMAZON VIEW HERE                     (dbo.vw_curated_amazon)
CREATE OR ALTER VIEW dbo.vw_curated_amazon AS
-- 5) Create final curated Amazon product-level view
SELECT
    -- product information
    m.parent_asin,
    m.main_category,
    m.title,
    CAST(m.average_rating AS DECIMAL(4,2)) AS average_rating,
    CAST(m.rating_number AS BIGINT) AS rating_number,
    CAST(m.price AS DECIMAL(18,2)) AS price,

    -- review sample information
    r.num_reviews_sample,
    r.total_helpful_votes
FROM dbo.vw_amazon_metadata_clean m

-- inner join = select only unique products with review info !
INNER JOIN dbo.vw_amazon_reviews_by_product r 
    ON m.parent_asin = r.parent_asin;
GO
SELECT -- verify 74,908 products (1 row per matched product)
    COUNT(*) AS total_rows,
    COUNT(DISTINCT parent_asin) AS unique_products
FROM dbo.vw_curated_amazon;
-- RESULT = find product IDs that exist in both lists
-- NOTE IMPORTANT -> because only 500k sample,
-- not every parent_asin in "metadata" also in "reviews"
-- thus only 74k matched products with both 


