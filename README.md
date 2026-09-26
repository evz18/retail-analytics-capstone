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

## Key Findings Across Datasets

### Amazon Reviews — Product Popularity

The Amazon analysis examined whether product characteristics could help explain
and predict product popularity.

- Random Forest achieved a ROC-AUC of approximately **0.694** for popularity
  classification.
- Gradient Boosting improved rating-count regression performance to approximately
  **R² = 0.227**, compared with **R² = 0.114** for the Linear Regression baseline.
- Average product rating was the dominant Random Forest feature, accounting for
  approximately **88% of feature importance**, substantially exceeding price and
  helpful-vote activity.
- Clustering identified distinct groups of products based on characteristics such
  as rating, price, and customer engagement.

These results suggest that product popularity contains meaningful nonlinear
patterns and that customer rating information is particularly informative when
distinguishing more popular products.


### Instacart — Product Reordering

The Instacart analysis examined whether order and product characteristics could
predict whether an item would be reordered.

- Random Forest achieved a ROC-AUC of approximately **0.65**, while K-Nearest
  Neighbors achieved approximately **0.63**.
- Support Vector Machine models produced ROC-AUC values of approximately
  **0.58–0.61**, depending on the kernel.
- Reordering was the most difficult of the four primary classification problems,
  with substantially weaker class separation than profitability prediction.

The results indicate that the available product and order characteristics contain
some predictive signal, but repeat purchasing is likely influenced by additional
customer preferences and behavioral factors not captured by these features.


### US E-Commerce — Profitability

The US E-Commerce analysis examined order profitability and geographic purchasing
patterns.

- Logistic Regression achieved a ROC-AUC of approximately **0.94** for
  profitability classification.
- Approximately **81% of observations were already profitable**, providing
  important context for interpreting the strong classification results.
- Random Forest achieved approximately **R² = 0.73** for profit regression,
  compared with approximately **R² = 0.22** for Linear Regression.
- Geographic analysis also identified meaningful differences in sales and order
  volume across regions.

The large improvement from Linear Regression to Random Forest suggests that
profitability is influenced by important nonlinear relationships among the
available transaction characteristics.


### Olist — Customer Satisfaction

The Olist analysis examined whether order, fulfillment, payment, product,
geographic, and temporal characteristics could predict positive customer reviews.

- Approximately **83% of on-time or early orders** received positive reviews,
  compared with only approximately **26–27% of late orders**.
- Positive-review rates decreased as order size increased, with approximately
  **81% positive reviews for one-item orders** compared with approximately
  **55% for orders containing six or more items**.
- Average delivery time and state-level positive-review rates showed a strong
  negative relationship of approximately **r = -0.82**.
- HistGradientBoosting achieved the highest observed classification performance
  at approximately **ROC-AUC = 0.706**.
- Delivery time and number of items were among the most important predictive
  features, while geography contributed relatively little to individual-level
  prediction.

These findings suggest that fulfillment performance and order complexity are
more informative indicators of customer satisfaction than transaction or
geographic characteristics alone.


## Cross-Dataset Insights

Analyzing the four datasets together revealed several broader patterns across
the retail customer and product lifecycle:

- **Nonlinear relationships were common.** Tree-based and boosting models often
  outperformed linear baselines, particularly for Amazon popularity and
  US E-Commerce profit prediction.

- **Predictability depended heavily on the business problem.** Profitability was
  comparatively predictable from the available transaction data, while
  individual product reordering was substantially more difficult to predict.

- **The most useful predictors changed across stages of the retail lifecycle.**
  Product ratings were especially informative for Amazon popularity, transaction
  characteristics helped explain profitability, and fulfillment performance and
  order complexity were important for Olist customer satisfaction.

- **EDA directly informed model development.** Variables such as price, sales,
  helpful votes, and order counts exhibited substantial skew, motivating
  transformations and scaling, while weak linear relationships supported the
  use of more flexible nonlinear models.

- **Descriptive relationships were not always strong predictive features.**
  For example, Olist showed meaningful geographic differences in satisfaction,
  but delivery performance was more useful for predicting individual customer
  outcomes.

Overall, the project demonstrates that **product demand, repeat purchasing,
profitability, and post-purchase satisfaction represent distinct retail
problems that require different features and modeling approaches rather than
a single universal predictor or algorithm**.

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
