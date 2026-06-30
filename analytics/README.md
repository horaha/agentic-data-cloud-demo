# Analytics Playground

This directory is used for analyzing and testing datasets, specifically the BigQuery public dataset `thelook_ecommerce`.

## Contents

- `notebooks/`: Jupyter Notebooks (`.ipynb`) for interactive analysis and metadata setup.
  - [01_data_profile_quality.ipynb](notebooks/01_data_profile_quality.ipynb): Automated data profiling and quality scans.
  - [02_data_insight.ipynb](notebooks/02_data_insight.ipynb): Automated column descriptions via Dataplex DataScans.
  - [03_dataset_insights.ipynb](notebooks/03_dataset_insights.ipynb): Exploratory dataset insights and statistics.
  - [04_glossary_setup.ipynb](notebooks/04_glossary_setup.ipynb): Loads the relational business glossary into Dataplex.
  - [05_graph_analysis.ipynb](notebooks/05_graph_analysis.ipynb): Property Graph creation, GQL multi-hop relationship analysis, and native visualization.
  - [06_bigquery_ai_ml_demo.ipynb](notebooks/06_bigquery_ai_ml_demo.ipynb): BigQuery Generative AI & ML analytics (remote LLM, embeddings, vector search).
  - [07_bigquery_ai_functions.ipynb](notebooks/07_bigquery_ai_functions.ipynb): BigQuery high-level AI functions (AI.CLASSIFY, AI.SIMILARITY, AI.IF, AI.SEARCH, Distillation).

- `resources/`: Supporting configuration and schema mapping files.
  - [agent_test_queries.md](resources/agent_test_queries.md): Verification guide and physical mapping scenarios.
  - [aspect_sql_mapping.json](resources/aspect_sql_mapping.json): Aspect schema definition for SQL mapping.
  - [business_glossary.json](resources/business_glossary.json): The custom Business Glossary terms.

## Local Development & Testing Guide

The notebooks in this project are primarily designed to run in cloud runtimes like Colab Enterprise. However, if you wish to run and test these notebooks locally, please refer to the instructions below.

### Dependency Syncing & Virtual Environment
You can manage and install the required dependencies using the `pyproject.toml` file. We recommend using **[uv](https://github.com/astral-sh/uv)** for fast and reliable environment synchronization.

```bash
# Create local virtual environment (.venv) and sync dependencies
uv sync
```

- `.venv/`: A local Python virtual environment containing the necessary libraries installed via uv.

