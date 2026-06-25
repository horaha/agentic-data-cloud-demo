# Analytics Playground

This directory is used for analyzing and testing datasets, specifically the BigQuery public dataset `thelook_ecommerce`.

## Dependency Management & Setup

This project manages dependencies using `pyproject.toml`. We recommend using **[uv](https://github.com/astral-sh/uv)** for fast and reliable environment synchronization.

```bash
# Sync dependencies and set up the virtual environment
uv sync
```

## Contents

- `notebooks/`: Jupyter Notebooks (`.ipynb`) for interactive analysis and metadata setup.
  - [01_data_profile_quality.ipynb](notebooks/01_data_profile_quality.ipynb): Automated data profiling and quality scans.
  - [02_metadata_effectiveness.ipynb](notebooks/02_metadata_effectiveness.ipynb): Tests the impact of metadata on LLM agents.
  - [03_schema_descriptions.ipynb](notebooks/03_schema_descriptions.ipynb): Automated column descriptions via Dataplex DataScans.
  - [04_dataset_insights.ipynb](notebooks/04_dataset_insights.ipynb): Exploratory dataset insights and statistics.
  - [05_glossary_setup.ipynb](notebooks/05_glossary_setup.ipynb): Loads the relational business glossary into Dataplex.
  - [06_graph_analysis.ipynb](notebooks/06_graph_analysis.ipynb): Property Graph and GQL recommendations.
  - [07_glossary_graph_setup.ipynb](notebooks/07_glossary_graph_setup.ipynb): Loads the graph-specific business glossary and links graph tables.
  - [08_bigquery_ai_ml_demo.ipynb](notebooks/08_bigquery_ai_ml_demo.ipynb): BigQuery Generative AI & ML analytics (remote LLM, embeddings, vector search).
  - [09_bigquery_ai_functions.ipynb](notebooks/09_bigquery_ai_functions.ipynb): BigQuery high-level AI functions (AI.CLASSIFY, AI.SIMILARITY, AI.IF, AI.SEARCH, Distillation).
  - [thelook_test.ipynb](notebooks/thelook_test.ipynb): Basic exploratory analysis template.

- `resources/`: Supporting configuration and schema mapping files.
  - [agent_test_queries.md](resources/agent_test_queries.md): Verification guide and physical mapping scenarios.
  - [aspect_physical_mapping.json](resources/aspect_physical_mapping.json): Aspect schema definition for physical mapping.
  - [business_glossary.json](resources/business_glossary.json): The custom Business Glossary terms.
- `.venv/`: Python virtual environment for installing dependencies.
