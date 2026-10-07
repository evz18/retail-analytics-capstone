# Retail Analytics Capstone

An end-to-end retail analytics project integrating **machine learning, cloud data engineering, SQL, and business intelligence** across four e-commerce datasets.

The project analyzes four stages of the retail lifecycle:

- **Amazon Reviews 2023:** Product popularity and demand
- **Instacart Market Basket Analysis:** Repeat purchasing behavior
- **US E-Commerce 2020:** Order profitability
- **Olist E-Commerce:** Post-purchase customer satisfaction

The workflow combines Python-based exploratory analysis and machine learning with an Azure analytics pipeline that transforms raw retail data into curated SQL views and interactive Power BI dashboards.

## Project Architecture

```text
Raw Retail Data
       ↓
Azure Blob Storage
       ↓
Azure Data Factory
       ↓
Processed Parquet
       ↓
Azure Synapse Serverless SQL
       ↓
Curated Analytics Views
       ↓
Power BI Dashboards
```

Python notebooks provide a parallel analytical workflow for:

```text
EDA → Feature Engineering → Machine Learning → Model Evaluation → Interpretation
```

## Power BI Dashboards

### Product Performance & Profitability

Analyzes US E-Commerce profitability and Amazon product performance.

![Product Performance Dashboard](powerbi/images/main_product_performance_dashboard.png)

**Key insights**
- The **West** generated the highest US E-Commerce total profit at approximately **$43.8K**.
- **Technology** was the most profitable product category at approximately **$50.7K**.
- Higher Amazon product ratings were generally associated with greater product popularity.
- **Amazon Devices** had the highest average rating count among the leading product categories.

### Customer Behavior & Retention

Analyzes Olist customer satisfaction and Instacart repeat purchasing behavior.

![Customer Behavior Dashboard](powerbi/images/customer_behavior_dashboard.png)

**Key insights**
- On-time/early Olist deliveries had a **80.6% positive-review rate**, compared with **34.6% for late deliveries**.
- Positive-review rates declined as order size increased.
- Instacart reorder rates increased from approximately **31.6% for customer orders 1–5** to **78.9% for orders 21+**.
- Products added earlier in the shopping cart had higher reorder rates.
- Dairy & Eggs, Beverages, and Produce were among the departments with the highest reorder rates.

See [`powerbi/README.md`](powerbi/README.md) for dashboard details.

## Machine Learning Results

Multiple supervised and unsupervised methods were evaluated across the four business problems, including Logistic and Linear Regression, KNN, SVM, Decision Trees, Random Forests, Gradient Boosting, K-Means, hierarchical clustering, and DBSCAN.

| Dataset | Business Problem | Selected Result |
|---|---|---|
| **Amazon** | Product popularity | Random Forest ROC-AUC **0.694** |
| **Amazon** | Rating-count regression | Gradient Boosting R² **0.227** |
| **Instacart** | Product reordering | Random Forest ROC-AUC **~0.63** |
| **US E-Commerce** | Profitability classification | Logistic Regression ROC-AUC **~0.94** |
| **US E-Commerce** | Profit regression | Random Forest R² **~0.73** |
| **Olist** | Positive-review prediction | HistGradientBoosting ROC-AUC **~0.706** |

### Modeling Insights

**Amazon — Product Popularity**
- Average product rating was the dominant Random Forest feature, accounting for approximately **88% of feature importance**.
- Nonlinear models outperformed the linear regression baseline for rating-count prediction.

**Instacart — Repeat Purchasing**
- Reordering was the most difficult classification problem, suggesting that repeat purchasing depends on behavioral information beyond the available product and order characteristics.
- Descriptive analysis showed particularly high reorder rates in Dairy & Eggs, Beverages, and Produce.

**US E-Commerce — Profitability**
- Approximately **81% of observations were profitable**, providing important context for the high classification ROC-AUC.
- Random Forest substantially outperformed Linear Regression for profit prediction, indicating important nonlinear relationships.

**Olist — Customer Satisfaction**
- Delivery performance was strongly associated with customer satisfaction.
- Delivery time and number of items were among the most informative predictive features.
- HistGradientBoosting produced the strongest observed classification performance at approximately **0.706 ROC-AUC**.

## Azure Data Engineering

The cloud pipeline standardizes the four source datasets for downstream analytics.

### Data Ingestion

- Raw source files are preserved in **Azure Blob Storage**.
- **Azure Data Factory** orchestrates raw-to-processed ingestion.
- Parameterized datasets and **ForEach** activities support reusable multi-file processing.
- Olist and Instacart CSV files are converted to **Parquet**.
- US E-Commerce is converted to Parquet with standardized column names.
- Amazon source data remains in its original Parquet format to avoid an unnecessary Parquet-to-Parquet processing step.
- Managed Identity and RBAC provide secure access between Azure services.

See [`azure/README.md`](azure/README.md) for implementation details.

## Synapse SQL Analytics Layer

**Azure Synapse Serverless SQL** provides the analytics layer between processed storage and Power BI.

The SQL workflow includes:

- External querying of Parquet data using `OPENROWSET`
- Data type standardization and safe conversion using `TRY_CAST`
- Multi-table joins for Olist and Instacart
- Aggregation to appropriate analytical grains
- Reusable curated views for all four datasets
- Business queries for profitability, popularity, satisfaction, and repeat purchasing
- Curated views consumed directly by Power BI

Examples include:

- `vw_curated_amazon`
- `vw_curated_instacart`
- `vw_curated_olist`
- `vw_curated_us_ecommerce`

SQL implementations are available in the [`sql/`](sql/) directory.

## Cross-Dataset Findings

Across the four datasets:

- **Different retail problems required different predictors and models.** No single algorithm or feature set performed best across demand, reordering, profitability, and satisfaction.
- **Nonlinear relationships were common.** Tree-based and boosting models frequently improved upon linear baselines.
- **Customer ratings were particularly informative for Amazon product popularity.**
- **Historical purchasing behavior was strongly associated with Instacart reordering.**
- **US E-Commerce profitability varied substantially by category and region.**
- **Olist fulfillment performance showed a strong relationship with customer satisfaction.**

Together, these findings demonstrate how analytics can support decisions across merchandising, customer retention, pricing, fulfillment, and product strategy.

## Technology Stack

**Data Science**
- Python
- pandas / NumPy
- scikit-learn
- Matplotlib / Seaborn

**Cloud & Data Engineering**
- Azure Blob Storage
- Azure Data Factory
- Parquet
- Azure Synapse Serverless SQL

**Business Intelligence**
- Power BI
- DAX
- Power Query

**Development**
- Git
- GitHub
- Jupyter / VS Code

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
├── sql/
│   ├── 01_setup.sql
│   ├── 02_1_us_ecommerce_views.sql
│   ├── 02_2_us_ecommerce_business_queries.sql
│   ├── 03_1_olist_views_joins.sql
│   ├── 03_2_olist_feature_engineering.sql
│   ├── 03_3_olist_business_queries.sql
│   ├── 04_1_instacart_views_joins.sql
│   ├── 04_2_instacart_business_queries.sql
│   ├── 05_1_amazon_views_joins.sql
│   └── 05_2_amazon_business_queries.sql
├── powerbi/
│   ├── README.md
│   └── images/
│       ├── product_performance_dashboard.png
│       └── customer_behavior_dashboard.png
├── .gitignore
└── README.md
```

## Current Status

- [x] Exploratory data analysis
- [x] Feature engineering
- [x] Machine learning
- [x] Azure data ingestion pipeline
- [x] Synapse Serverless SQL analytics layer
- [x] Interactive Power BI dashboards
- [ ] Streamlit model deployment
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
