# Cloud Run Deployment Guide using Terraform

This guide details how to build and deploy the **Knowledge Catalog Business Interface** web application to Google Cloud Run using the unified root-level Terraform configuration and Cloud Build.

## Directory Structure
- `terraform/infra/business_ui.tf`: Defines the Artifact Registry repository, Cloud Run v2 service, and public IAM access bindings (`allUsers`).
- `business-ui/deploy.sh`: Automated shell script executing environment validation, Artifact Registry provisioning, Cloud Build image compilation, and Cloud Run deployment.

---

## Deployment Steps

### 1. Prerequisites
- Ensure Google Cloud SDK (`gcloud` CLI) is installed and authenticated.
- Authenticate both `gcloud` CLI and Application Default Credentials (ADC), and set your active project:
  ```shell
  gcloud auth login
  gcloud auth application-default login
  gcloud config set project YOUR_PROJECT_ID
  ```
- Make sure Billing is enabled on your GCP project.

### 2. Create Google OAuth Client ID & Configure Variables (`terraform.tfvars`)
1. Go to [GCP Console Credentials](https://console.cloud.google.com/apis/credentials) ➔ **+ CREATE CREDENTIALS ➔ OAuth client ID** (Web application) to create your client ID.
   - **Authorized JavaScript origins**: `http://localhost:8080`
   - **Authorized redirect URIs**: `http://localhost:8080/auth/google/callback`
2. Copy the generated Client ID and update `../terraform/infra/terraform.tfvars`:
```shell
nano ../terraform/infra/terraform.tfvars
```

Ensure the variables are configured:
```hcl
project_id      = "YOUR_PROJECT_ID"
region          = "asia-northeast3"
oauth_client_id = "YOUR_OAUTH_CLIENT_ID.apps.googleusercontent.com"
admin_email     = "your-admin-email@example.com"
```

### 3. Run the Deployment Script
Execute the `deploy.sh` script from the `business-ui` directory:
```shell
./deploy.sh
```

The script will automatically:
1. Validate `gcloud` project ID and Application Default Credentials (ADC).
2. Auto-synchronize `terraform.tfvars` and reset stale Terraform state if the active GCP project changed.
3. Automatically handle existing Artifact Registry repositories (`dataplex-ui-repo`) and Cloud Run services via `terraform import` to prevent conflict errors (Error 409).
4. Build the Docker container image via Cloud Build and push it to Artifact Registry.
5. Deploy the Cloud Run v2 service and output the live service URL!

### 4. Post-Deployment: Configure OAuth & Access Application

#### A. Add Cloud Run URL to Google OAuth Authorized Origins
Add your live Service URL to the Google OAuth Client ID created in Step 2:
1. Go to **APIs & Services > Credentials** in GCP Console.
2. Click the Web Client created in Step 2.
3. In **Authorized JavaScript origins**, add the printed Cloud Run URL (e.g. `https://dataplex-business-ui-xxxx.run.app`).
4. In **Authorized redirect URIs**, add the printed redirect URL (e.g. `https://dataplex-business-ui-xxxx.run.app/auth/google/callback`).
5. Click **Save**.

#### B. Accessing the Application
- **Direct Access**: Since `deploy.sh` automatically configures IAM invoker access (`allUsers` or active account/domain access), open the printed **Service URL** (e.g., `https://dataplex-business-ui-xxxx.run.app`) directly in your web browser. No proxy command is required.

#### C. Google OAuth Sign-in Consent
When signing in with Google, ensure you select **"Select all"** or check all requested permission boxes (`Google Cloud Platform`, `BigQuery`, `Dataplex`) on the Google consent screen to ensure full access to metadata and analytics.
