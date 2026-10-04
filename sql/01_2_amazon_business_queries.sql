-- NOTE:
-- rating_number = overall number of ratings for the product from Amazon metadata (~3 million rows info)
-- num_reviews_sample = number of reviews for the product found in our 500k review sample
-- total_helpful_votes = helpful votes summed only across those 500k sampled reviews
-- Therefore, rating_number reflects broader product popularity, while the
-- review-derived variables only describe the reviews included in our sample.


-- 1) Average rating vs product popularity
-- "Do products with higher average ratings have more total ratings"
SELECT
    CASE
        WHEN average_rating < 3 THEN 'Below 3.0'
        WHEN average_rating < 4 THEN '3.0-3.9'
        WHEN average_rating < 4.5 THEN '4.0-4.4'
        ELSE '4.5+'
    END AS rating_group,
    COUNT(*) AS num_products,
    -- rating_number = total number of ratings for the product
    ROUND(AVG(CAST(rating_number AS FLOAT)), 2) AS avg_rating_count
FROM dbo.vw_curated_amazon
WHERE average_rating IS NOT NULL
  AND rating_number IS NOT NULL
-- output = each rating group, num products per group, avg_num ratings per group
GROUP BY
    CASE
        WHEN average_rating < 3 THEN 'Below 3.0'
        WHEN average_rating < 4 THEN '3.0-3.9'
        WHEN average_rating < 4.5 THEN '4.0-4.4'
        ELSE '4.5+'
    END
ORDER BY MIN(average_rating);
-- Results: Products with higher average ratings had substantially higher
-- rating counts, with 4.5+ rated products averaging ~2,880 ratings compared
-- with ~38 for products rated below 3.0.


-- 2) Product price vs popularity
-- 'Do lower or higher-priced products have more ratings/popularity'
SELECT
    CASE    
        WHEN price <25 THEN 'Under $25'
        WHEN price <50 THEN '$25-$49.99'
        WHEN price <100 THEN '$50-$99.99'
        ELSE '$100+'
    END AS price_group,
    COUNT(*) AS num_products,
    -- avg num of ratings per product
    ROUND(AVG(CAST(rating_number AS FLOAT)),2) AS avg_rating_count
FROM dbo.vw_curated_amazon
WHERE price IS NOT NULL AND rating_number IS NOT NULL

GROUP BY
    CASE    
        WHEN price <25 THEN 'Under $25'
        WHEN price <50 THEN '$25-$49.99'
        WHEN price <100 THEN '$50-$99.99'
        ELSE '$100+'
    END 
ORDER BY MIN(price);
-- Results: Lower-priced products generally had higher rating counts,
-- while products priced at $100+ averaged only ~1,607 ratings.
-- The relationship was weaker than the pattern observed for average rating.


-- 3) Helpful votes vs product popularity
-- 'Do products whose sampled reviews received more helpful votes also have higher overall rating counts'
SELECT
    CASE
        WHEN total_helpful_votes = 0 THEN '0 votes'
        WHEN total_helpful_votes <= 10 THEN '1-10 votes'
        WHEN total_helpful_votes <= 100 THEN '11-100 votes'
        ELSE '100+ votes'
    END AS helpful_vote_group,
    COUNT(*) AS num_products,
    -- average number of ratings per product
    ROUND(AVG(CAST(rating_number AS FLOAT)), 2) AS avg_rating_count
FROM dbo.vw_curated_amazon
WHERE total_helpful_votes IS NOT NULL
  AND rating_number IS NOT NULL

GROUP BY
    CASE
        WHEN total_helpful_votes = 0 THEN '0 votes'
        WHEN total_helpful_votes <= 10 THEN '1-10 votes'
        WHEN total_helpful_votes <= 100 THEN '11-100 votes'
        ELSE '100+ votes'
    END
ORDER BY MIN(total_helpful_votes);
-- Results: Products with more helpful votes in the review sample had
-- substantially higher overall rating counts. Products with 100+ helpful
-- votes averaged ~23,042 ratings compared with ~634 for products with none.


-- 4) Product popularity by category
SELECT TOP 10
    main_category,
    COUNT(*) AS num_products,
    -- average overall number of ratings per product
    ROUND(AVG(CAST(rating_number AS FLOAT)), 2) AS avg_rating_count
FROM dbo.vw_curated_amazon
WHERE main_category IS NOT NULL
  AND rating_number IS NOT NULL

-- ouput = category, num_products, avg num ratings 
GROUP BY main_category
-- avoid tiny categories producing misleading averages
HAVING COUNT(*) >= 100
ORDER BY avg_rating_count DESC;
-- Results: Amazon Devices and Apple Products had the highest average
-- product rating counts at ~11,734 and ~10,096 ratings per product,
-- substantially exceeding the other qualifying categories.
