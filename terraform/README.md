# GCP Infrastructure Provisioning with Terraform

This repository is designed to manage infrastructure resources for the Agentic Data Cloud Demo.

## Directory Structure

This project has been consolidated into a **centralized module management** and **single-project deployment** structure for better readability and easier management.

```text
.
├── modules/                  # Reusable modules
│   ├── api/                  # Enable GCP APIs
│   ├── vpc/                  # Create VPC and Subnets
│   ├── iam/                  # Manage IAM Service Accounts and Roles
│   └── gcs/                  # Manage Cloud Storage buckets
│
└── infra/                    # Integrated infrastructure definition
    ├── main.tf               # Defines all resources (APIs, VPC, GCS, BigQuery, IAM, Colab)
    ├── variables.tf          # Global variables
    ├── outputs.tf            # Integrated outputs (mainly VPC resources)
    ├── versions.tf           # Terraform and provider configurations with GCS backend
    └── terraform.tfvars      # User-defined variables (project_id, region)
```

### Key Improvements
1. **Simplified Deployment**: All resources are unified under the `infra/` folder. You can provision the entire infrastructure with a single `terraform apply`.
2. **Simplified Dependency Management**: Internal resource dependencies (like Colab using VPC subnets) are resolved natively in `main.tf` instead of relying on `terraform_remote_state` data sources.
3. **Local Reusable Modules**: The modules are placed directly under `terraform/modules/` for better self-containment.

## Initial Setup: Create Terraform State Bucket

This is a one-time setup step per project. Before running Terraform, you should create a GCS bucket to store the Terraform state file remotely.

We recommend using the naming convention `tfstate-<your-gcp-project-id>-asne3` (e.g., `tfstate-myproject-asne3` for `asia-northeast3`).

```bash
# 1. Set your GCP Project ID
gcloud config set project <your-gcp-project-id>

# 2. Create the GCS bucket
gcloud storage buckets create gs://tfstate-<your-gcp-project-id>-asne3 --location asia-northeast3 --uniform-bucket-level-access
```

> **Note**: If you want to use a different bucket name, make sure to update the `bucket` parameter in `infra/versions.tf`.

## Execution

Since all resources and their dependencies are defined in a single place, you can deploy everything with these simple commands:

```bash
cd infra

# Initialize Terraform (will download providers and local modules)
terraform init

# Plan and review the infrastructure changes
terraform plan

# Apply changes to provision the infrastructure
terraform apply
```

## Notes
* Copy `infra/terraform.tfvars.example` to `infra/terraform.tfvars` and update the `project_id` and `region` variables with your actual target GCP values before running.
* The state is stored remotely using the **GCS (Google Cloud Storage)** backend configured in `infra/versions.tf`.
