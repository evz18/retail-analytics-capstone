# Power BI Retail Analytics Dashboard

Interactive Power BI dashboard built from curated retail datasets queried through Azure Synapse Serverless SQL.

## Dashboard Overview

The report contains two pages focused on product performance, profitability, customer satisfaction, and repeat purchasing behavior.

### 1. Product Performance & Profitability

Analyzes US E-Commerce profitability and Amazon product performance.

Key findings:
- The West generated the highest total profit at approximately $43.8K.
- Technology was the most profitable product category at approximately $50.7K.
- Higher Amazon product ratings were generally associated with greater product popularity.
- Amazon Devices had the highest average rating count among the leading product categories.

![Product Performance Dashboard](images/product_performance_dashboard.png)

### 2. Customer Behavior & Retention

Analyzes Olist customer satisfaction and Instacart repeat purchasing behavior.

Key findings:
- On-time/early Olist deliveries had substantially higher positive review rates than late deliveries.
- Positive review rates declined as order size increased.
- Instacart reorder rates increased substantially with customer order history.
- Products added earlier in the cart had higher reorder rates.
- Dairy & Eggs, Beverages, and Produce were among the departments with the highest reorder rates.

![Customer Behavior Dashboard](images/customer_behavior_dashboard.png)

## Power BI Features

- Interactive slicers for region, product category, and customer state
- KPI cards for sales, profit, discount, ratings, review satisfaction, and reorder behavior
- DAX measures and calculated columns for dynamic business metrics
- Cross-filtering within individual retail datasets
- Consistent visual encoding across datasets

## Data Pipeline

Raw Data → Azure Blob Storage → Azure Data Factory → Parquet → Azure Synapse Serverless SQL → Curated SQL Views → Power BI

Power BI connects to the curated Synapse views rather than directly to the raw source files.
