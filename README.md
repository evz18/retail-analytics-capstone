# Retail Analytics Capstone

An end-to-end retail analytics project analyzing product demand, repeat purchasing,
profitability, and customer satisfaction across four e-commerce datasets.

The project combines Python-based exploratory data analysis and machine learning
with Azure data engineering, SQL, and Power BI to develop a complete analytics
workflow from raw data to business insights.

## Project Objectives

This project examines different stages of the retail customer and product lifecycle:

- **Amazon Reviews 2023:** Product popularity and demand
- **Instacart Market Basket Analysis:** Product reordering behavior
- **US E-Commerce 2020:** Order profitability
- **Olist E-Commerce:** Post-purchase customer satisfaction

## Technology Stack

- Python
- pandas / NumPy
- scikit-learn
- Matplotlib / Seaborn
- Git / GitHub
- Azure Blob Storage
- Azure Data Factory
- Parquet
- Azure Synapse SQL *(in progress)*
- Power BI *(planned)*

## Project Architecture

Current end-to-end architecture:

Raw Retail Data  
↓  
Python EDA & Machine Learning  
↓  
Azure Blob Storage  
↓  
Azure Data Factory  
↓  
Processed Parquet  
↓  
Curated Analytics Layer *(in progress)*  
↓  
Synapse SQL  
↓  
Power BI

## Machine Learning

The project evaluates multiple supervised and unsupervised learning methods,
including:

- Logistic and Linear Regression
- K-Nearest Neighbors
- Support Vector Machines
- Decision Trees and Random Forests
- Gradient Boosting
- K-Means Clustering
- Hierarchical Agglomerative Clustering
- DBSCAN

Model performance is evaluated using appropriate classification, regression,
and clustering metrics such as ROC-AUC, RMSE, R², and silhouette score.

## Olist Customer Satisfaction Analysis

The Olist analysis investigates whether order, fulfillment, payment, product,
geographic, and temporal characteristics can predict whether a customer leaves
a positive review.

Key findings include:

- Approximately 83% of on-time or early orders received positive reviews,
  compared with approximately 27% of late orders.
- Positive-review rates decreased as order size increased.
- Delivery time and number of items were important predictive features.
- HistGradientBoosting produced the highest observed ROC-AUC at approximately 0.706.
- Geographic differences were useful descriptively but contributed relatively
  little to individual-level prediction.

Overall, fulfillment performance and order complexity were more informative
indicators of customer satisfaction than transaction or geographic
characteristics alone.

## Azure Data Pipeline

The cloud data-engineering portion of the project uses Azure Blob Storage and
Azure Data Factory.

The Olist ingestion pipeline currently:

- Preserves original source files in a raw data layer
- Uses Azure Managed Identity and RBAC for secure storage access
- Uses parameterized source and sink datasets
- Uses an Azure Data Factory ForEach activity to process multiple source files
- Converts raw CSV files into analytics-optimized Parquet files
- Processes all nine Olist source tables through a reusable ingestion workflow

See [`azure/README.md`](azure/README.md) for implementation details.

## Repository Structure

    retail-analytics-capstone/
    ├── amazon/
    ├── instacart/
    ├── us_ecommerce/
    ├── olist/
    ├── azure/
    │   └── README.md
    ├── .gitignore
    └── README.md

## Current Status

- Python EDA and machine learning: Complete
- Olist customer satisfaction analysis: Complete
- Azure raw data ingestion: Complete
- Azure processed Parquet layer: Complete
- Curated analytics layer: In progress
- Synapse SQL analysis: Planned
- Power BI dashboard: Planned