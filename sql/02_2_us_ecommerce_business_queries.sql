-- C1) CURATED VIEW check profitability by region
SELECT 
    region,
    COUNT(*) AS num_orders,
    ROUND(AVG(profit),2) AS avg_profit,
    ROUND(SUM(profit),2) AS total_profit
FROM dbo.vw_curated_us_ecommerce
GROUP BY region
ORDER BY total_profit DESC;
-- Results: The West was the most profitable region, generating ~$43,809
-- in total profit and the highest average profit per order at ~$40.01.
-- The Central region was least profitable, averaging only ~$9.71 per order.

-- C2) CURATED VIEW profitability by product category
SELECT
    category,
    COUNT(*) AS num_orders,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    ROUND(AVG(profit),2) AS avg_profit
FROM dbo.vw_curated_us_ecommerce
GROUP BY category
ORDER BY total_profit DESC;
-- Results: Technology was the most profitable category, generating ~$50,685
-- in total profit and ~$81.23 average profit per order. Furniture was substantially
-- less profitable, generating only ~$3,018 total profit and ~$4.40 per order.
