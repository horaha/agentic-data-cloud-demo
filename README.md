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

To run this demo, follow these two steps:

### Step 1: Provision Infrastructure
Set up the necessary GCP resources (APIs, VPC, BigQuery dataset, GCS bucket, IAM, and Colab templates) using Terraform.
* Refer to the [Terraform Guide](terraform/README.md) for detailed deployment steps.

```bash
cd terraform/infra
# Copy and update variables
cp terraform.tfvars.example terraform.tfvars
# Deploy
terraform init
terraform apply
```

### Step 2: Run Data Analytics & AI Notebooks
Once the infrastructure is up, run the interactive analysis notebooks.
* Refer to the [Analytics Guide](analytics/README.md) for dependency setup and notebook details.

```bash
cd analytics
# Install dependencies using uv
uv sync
# Open Jupyter Notebook or upload to Vertex AI Workbench/Colab Enterprise
```

## License
This project is licensed under the Apache 2.0 License - see the LICENSE details.
