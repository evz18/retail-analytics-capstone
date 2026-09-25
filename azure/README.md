# Azure Data Pipeline

This portion of the project extends the retail analytics workflow into
a cloud-based data pipeline using Azure Blob Storage and Azure Data Factory.

## Architecture

Raw Retail Data
→ Azure Blob Storage
→ Azure Data Factory
→ Processed Parquet
→ Curated Data
→ Synapse SQL
→ Power BI

## Current Progress

- Created a dedicated `retail-capstone` Blob Storage container
- Organized source data into raw folders for Amazon, Instacart,
  US E-Commerce, and Olist
- Configured Azure Data Factory access using a system-assigned
  Managed Identity and Azure RBAC
- Created parameterized source and sink datasets
- Built a reusable ForEach ingestion pipeline for the nine Olist source files
- Converted raw Olist CSV files into processed Parquet files
- Debugged a CSV parsing issue in the free-text reviews dataset by
  correcting the escape-character configuration
- Successfully executed the complete Olist ingestion pipeline

## Pipeline Design

The Olist pipeline uses an array of source and destination filenames.
Azure Data Factory's ForEach activity iterates through the array and
passes the current filenames to a parameterized Copy activity.

This allows one reusable pipeline to process all nine Olist files rather
than creating a separate activity for each source.

## Next Steps

- Build curated analytics-ready datasets
- Query transformed data with Synapse SQL
- Create SQL aggregations and analytical views
- Connect curated data to Power BI
- Build an interactive retail analytics dashboard