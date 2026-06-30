# Agentic Data Cloud Demo

This repository contains the code and configuration for the **Agentic Data Cloud Demo**, showing how to build an AI-ready data cloud infrastructure on Google Cloud and perform advanced data analytics using Gemini and BigQuery.

## Repository Structure

The project is divided into two primary directories:

```text
.
├── terraform/                # Infrastructure-as-code to provision GCP resources
│   ├── modules/              # Reusable Terraform modules (API, VPC, GCS, IAM)
│   └── infra/                # Unified root module to deploy the entire demo stack
│
└── analytics/                # Data analysis and AI playground using Python/Jupyter
    ├── notebooks/            # Jupyter notebooks for data quality, catalog, graphs, and AI
    ├── resources/            # Business glossary and schema aspect definitions
    └── pyproject.toml        # Modern Python dependency configuration (managed via uv)
```

## Getting Started

To run this demo, you can spin up the entire stack with a single command on **Google Cloud Shell**.

### Step 1: Clone Repository & Run Auto Setup

In your Google Cloud Shell, clone this repository and execute the auto-setup script. This script automatically detects your active GCP project, configures variables, and deploys the GCP infrastructure using Terraform.

```bash
git clone https://github.com/horaha/agentic-data-cloud-demo.git
cd agentic-data-cloud-demo

# Make sure you are in the correct active project
gcloud config get-value project

./setup.sh
```

### Step 2: Run Data Analytics & AI Notebooks
Once the infrastructure is up, you can run the interactive analysis notebooks.
* Refer to the [Analytics Guide](analytics/README.md) for local python environment setup and notebook details.
* You can also run these notebooks in **Colab Enterprise** templates deployed by Terraform.


## License
This project is licensed under the Apache 2.0 License - see the LICENSE details.
