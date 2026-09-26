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
- Azure Synapse Serverless SQL *(next stage)*
- Power BI *(planned)*

## Project Architecture

The project combines a Python-based analytics workflow with a cloud
data-engineering and business intelligence pipeline.

Cloud analytics architecture:

Raw Retail Data\
↓\
Azure Blob Storage (Raw Layer)\
↓\
Azure Data Factory\
↓\
Processed Parquet\
↓\
Azure Synapse Serverless SQL *(next stage)*\
↓\
Curated Analytics Layer\
↓\
Power BI *(planned)*

Python notebooks are used separately for exploratory data analysis, feature
engineering, machine learning, model evaluation, and interpretation across the
four retail datasets.

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
Azure Data Factory to ingest and standardize the four retail datasets.

The ingestion workflow:

- Preserves original source files in a raw data layer
- Uses Azure Managed Identity and RBAC for secure storage access
- Uses parameterized source and sink datasets
- Uses Azure Data Factory ForEach activities for reusable multi-file ingestion
- Converts Olist and Instacart CSV source files into Parquet
- Converts the US E-Commerce CSV into Parquet and standardizes column names to
  snake_case
- Retains Amazon source files in their existing Parquet format until meaningful
  downstream transformations are performed
- Stores standardized outputs in a processed data layer for downstream SQL analysis

See [azure/README.md](azure/README.md) for implementation details.

## Data Ingestion Status

The raw-to-processed ingestion stage is complete.

- **Olist:** Nine CSV files converted to Parquet using a parameterized ADF
  ForEach pipeline.
- **Instacart:** Six CSV files converted to Parquet using a reusable parameterized
  ADF ForEach pipeline.
- **US E-Commerce:** CSV converted to Parquet with column names standardized to
  snake_case for downstream SQL analysis.
- **Amazon Reviews:** Source data was already stored as Parquet, so an unnecessary
  Parquet-to-Parquet processing step was intentionally avoided.

### Pipeline Features

- Azure Blob Storage raw and processed layers
- Azure Data Factory orchestration
- Parameterized datasets and dynamic content
- ForEach activities for multi-file ingestion
- Managed Identity authentication with RBAC
- CSV-to-Parquet conversion with Snappy compression
- Schema standardization for downstream analytics
- Pipeline validation and targeted debugging of CSV parsing and dynamic parameters

## Repository Structure

```text
retail-analytics-capstone/
├── amazon/
│   └── amazon_analysis.ipynb
├── instacart/
│   └── instacart_analysis.ipynb
├── us_ecommerce/
│   └── us_ecommerce_analysis.ipynb
├── olist/
│   └── Olist_dataset.ipynb
├── azure/
│   └── README.md
├── .gitignore
└── README.md
