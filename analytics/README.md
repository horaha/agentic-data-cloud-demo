# Analytics Playground

This directory is used for analyzing and testing datasets, specifically the BigQuery public dataset `thelook_ecommerce`.

## Contents

- `notebooks/`: Jupyter Notebooks (`.ipynb`) for interactive analysis and metadata setup.
  - [01_data_profile_quality.ipynb](notebooks/01_data_profile_quality.ipynb): Automated data profiling and quality scans.
  - [02_metadata_effectiveness.ipynb](notebooks/02_metadata_effectiveness.ipynb): Tests the impact of metadata on LLM agents.
  - [03_schema_descriptions.ipynb](notebooks/03_schema_descriptions.ipynb): Automated column descriptions via Dataplex DataScans.
  - [04_dataset_insights.ipynb](notebooks/04_dataset_insights.ipynb): Exploratory dataset insights and statistics.
  - [05_glossary_setup.ipynb](notebooks/05_glossary_setup.ipynb): Loads the relational business glossary into Dataplex.
  - [06_graph_analysis.ipynb](notebooks/06_graph_analysis.ipynb): Property Graph creation, GQL multi-hop relationship analysis, and native visualization.
  - [07_bigquery_ai_ml_demo.ipynb](notebooks/07_bigquery_ai_ml_demo.ipynb): BigQuery Generative AI & ML analytics (remote LLM, embeddings, vector search).
  - [08_bigquery_ai_functions.ipynb](notebooks/08_bigquery_ai_functions.ipynb): BigQuery high-level AI functions (AI.CLASSIFY, AI.SIMILARITY, AI.IF, AI.SEARCH, Distillation).

- `resources/`: Supporting configuration and schema mapping files.
  - [agent_test_queries.md](resources/agent_test_queries.md): Verification guide and physical mapping scenarios.
  - [aspect_sql_mapping.json](resources/aspect_sql_mapping.json): Aspect schema definition for SQL mapping.
  - [aspect_graph_mapping.json](resources/aspect_graph_mapping.json): Aspect schema definition for graph mapping.
  - [business_glossary.json](resources/business_glossary.json): The custom Business Glossary terms.
  - [business_glossary_graph.json](resources/business_glossary_graph.json): The custom Business Glossary terms for graph tables.

