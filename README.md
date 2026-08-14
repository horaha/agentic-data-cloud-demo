# Agentic Data Cloud Demo

This repository contains the code and configuration for the **Agentic Data Cloud Demo**, showing how to build an AI-ready data cloud infrastructure on Google Cloud and perform advanced data analytics using Gemini and BigQuery.

## Repository Structure

The project is divided into two primary directories:

```text
.
├── terraform/                # Infrastructure-as-code to provision GCP resources
│   ├── modules/              # Reusable Terraform modules (API, VPC, GCS, IAM)
│   └── infra/                # Unified root module to deploy the entire demo stack (including UI resources)
│
├── analytics/                # Data analysis and AI playground using Python/Jupyter
│   ├── notebooks/            # Jupyter notebooks for data quality, catalog, graphs, and AI
│   ├── resources/            # Business glossary and schema aspect definitions
│   └── pyproject.toml        # Modern Python dependency configuration (managed via uv)
│
└── business-ui/              # React/Express web application for business users (Knowledge Catalog UI)
    ├── src/                  # React frontend code (Material UI, Redux Toolkit)
    ├── backend/              # Node.js backend server (Express, Dataplex integration)
    ├── deploy.sh             # Automated script to build and deploy to Google Cloud Run
    └── README.deploy.md      # Detailed Cloud Run deployment instructions
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

### Step 3: Deploy the Business UI to Cloud Run (Optional)
The **Business UI (Optional)** provides business users with a graphical search and metadata discovery portal. You can deploy it to Google Cloud Run in a single step when needed.

#### 1. Create & Configure Google OAuth Client ID (Required Once)
1. Go to [GCP Console Credentials](https://console.cloud.google.com/apis/credentials) ➔ **+ CREATE CREDENTIALS ➔ OAuth client ID** (Web application).
2. **Authorized JavaScript origins**: `http://localhost:8080`
3. **Authorized redirect URIs**: `http://localhost:8080/auth/google/callback`
4. Copy the generated Client ID and add it to `terraform/infra/terraform.tfvars`:
   ```hcl
   oauth_client_id = "YOUR_OAUTH_CLIENT_ID.apps.googleusercontent.com"
   ```

#### 2. Run Automated Deployment
```shell
cd business-ui
./deploy.sh
```
*(For detailed deployment mechanics, check the [UI Deployment Guide](business-ui/README.deploy.md).)*

#### 3. Access & OAuth Permission Consent
* **Proxy Access (If Organization Policy Enforced):** If GCP Organization Policy (Domain Restricted Sharing) causes `403 Forbidden` on direct Cloud Run URLs, start a local proxy:
  ```shell
  gcloud run services proxy dataplex-business-ui --region=asia-northeast3 --project=YOUR_PROJECT_ID --port=8080
  ```
  (Access via `http://localhost:8080` or Cloud Shell Web Preview on port 8080).
* **OAuth Permission Consent:** When logging in via Google OAuth, ensure you select **"Select all"** or check all permission boxes (`Google Cloud Platform`, `BigQuery`, `Dataplex`) on the Google consent screen.

## License
This project is licensed under the Apache 2.0 License - see the LICENSE details.
