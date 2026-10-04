# SQL Analytics Layer
This directory contains the SQL analytics layer for the Retail Analytics Capstone. Azure Synapse Serverless SQL was used to query Parquet datasets stored in Azure Storage, integrate related tables, standardize data types, engineer analytical features, and create reusable curated views for downstream analysis and visualization.

## Architecture
**Azure Blob Storage → Azure Data Factory → Processed Parquet → Synapse Serverless SQL → Curated Views → Power BI**
Azure Data Factory handles data movement into the processed storage layer, while Synapse performs transformations and analytical querying directly over the Parquet files.

## Dataset Structure

### Amazon Reviews
The Amazon pipeline combines independently sampled review and product metadata files using `parent_asin`. Review-level records are aggregated to the product level before joining to metadata, producing a curated dataset with one row per matched product.
Key transformations include identifier normalization, metadata deduplication, review aggregation, and integration of product attributes with sampled review activity.

**Key findings:**
- Products with higher average ratings had substantially higher overall rating counts.
- Products rated 4.5+ averaged approximately 2,880 ratings compared with approximately 38 for products rated below 3.0.
- Products with greater sampled helpful-vote activity also tended to have substantially higher overall rating counts.
- Amazon Devices and Apple Products had the highest average rating counts among qualifying categories.

### US E-Commerce
The US E-Commerce pipeline converts source fields into analytics-ready numeric and date types and creates a curated view for profitability analysis.

**Key findings:**
- The West generated the highest regional profit at approximately $43.8K.
- Technology was the most profitable product category, generating approximately $50.7K in total profit and $81 average profit per order.
- Furniture produced substantially lower profitability than the other major categories.

### Olist E-Commerce
Multiple Olist source tables are integrated into an order-level analytical view. SQL feature engineering creates measures for delivery performance, order size, payments, sellers, and customer reviews.

**Key findings:**
- On-time or early deliveries had an approximately 80.6% positive-review rate compared with 34.6% for late deliveries.
- Larger orders were associated with substantially lower customer satisfaction.
- Longer installment plans showed a modest decline in positive-review rate.

### Instacart
Orders, products, aisles, departments, and order-product records are integrated into a curated product-order view for repeat-purchase analysis.

**Key findings:**
- Dairy & Eggs had the highest department-level reorder rate at approximately 67%.
- Products added earlier to the cart had higher reorder rates.
- Reorder rates increased substantially with customer order history.
- More frequent orders contained a greater proportion of previously purchased products.

## SQL Techniques
The SQL layer demonstrates:
- Azure Synapse Serverless SQL and `OPENROWSET`
- External Parquet querying
- Reusable base and curated views
- Multi-table joins
- Grain and cardinality validation
- Aggregation and feature engineering
- CTEs
- `CASE` expressions
- `GROUP BY` and `HAVING`
- Data type standardization with `CAST`
- Deduplication and identifier normalization
- Business-oriented analytical queries

## Files
- `01_1_amazon_views_joins.sql` — Amazon source views, review aggregation, cleaning, joins, and curated view
- `01_2_amazon_business_queries.sql` — Amazon product popularity analysis
- `02_1_us_ecommerce_views.sql` — US E-Commerce source and curated views
- `02_2_us_ecommerce_business_queries.sql` — regional and category profitability analysis
- `03_1_olist_views_joins.sql` — Olist source views and joins
- `03_2_olist_feature_engineering.sql` — Olist order-level feature engineering and curated view
- `03_3_olist_business_queries.sql` — delivery and customer-satisfaction analysis
- `04_1_instacart_views_joins.sql` — Instacart source views, integration, and curated view
- `04_2_instacart_business_queries.sql` — repeat-purchase behavior analysis

These curated Synapse views form the analytical layer used for downstream Power BI reporting and complement the Python-based exploratory analysis and machine-learning components of the broader capstone.
