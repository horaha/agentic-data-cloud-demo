# GEMINI.md - AI Assistant Notes

This file serves as a guideline to help the AI assistant (Gemini / Antigravity) understand and maintain the code in this repository.

## 🤖 Assistant Role
This repository is designed to provision infrastructure resources for the Agentic Data Cloud Demo. The AI assistant should maintain the consistency of this consolidated structure and provide guidance when modifying configurations.

## 📐 Architecture Guidelines

Follow these rules when adding or modifying infrastructure resources.

### 1. Adding Modules (`modules/`)
* Write **pure, reusable resource definitions** that are not dependent on a specific project.
* `project_id` must always be received as a variable.
* Specify only the minimum required variables for resource creation, and provide sensible defaults for the rest.
* Maintain modules under the `terraform/modules/` directory.

### 2. Consolidated Infrastructure (`infra/`)
* All infrastructure components (APIs, VPC, GCS, BigQuery, IAM, Colab, etc.) must be defined and managed within the unified `terraform/infra/` directory.
* Avoid using `terraform_remote_state` to reference dependencies between components. Instead, chain them directly in `main.tf` (e.g., using `module.vpc.network_id`) and enforce ordering via `depends_on` when necessary.
* Keep project-specific values defined via `terraform.tfvars`.

### 3. Documentation
* When modifying `README.md` or `GEMINI.md`, you **must** always update the corresponding Korean version (`README.ko.md` or `GEMINI.ko.md`) to keep them synchronized.
