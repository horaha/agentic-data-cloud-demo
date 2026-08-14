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

### 2. Configure Variables (Optional)
The deployment script automatically detects your active GCP project (`PROJECT_ID`) and account email. To add your Google OAuth Client ID, update `terraform.tfvars`:
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

#### A. Configure Google OAuth JavaScript Origins
Add your Service URL (or local proxy URL `http://localhost:8080`) to your Google Cloud Console Credentials page:
1. Go to **APIs & Services > Credentials > Web Client**.
2. In **Authorized JavaScript origins**, add: `http://localhost:8080` (or the printed Cloud Run URL e.g. `https://dataplex-business-ui-xxxx.run.app`)
3. In **Authorized redirect URIs**, add: `http://localhost:8080/auth/google/callback` (or the printed URL e.g. `https://dataplex-business-ui-xxxx.run.app/auth/google/callback`)
4. Click **Save**.

#### B. Accessing the Application
- **Direct Access**: Open the Cloud Run URL if public unauthenticated access (`allUsers`) is permitted in your organization.
- **Proxy Access (If GCP Organization Policy Enforced)**: If Domain Restricted Sharing blocks `allUsers` access, run the local proxy:
  ```shell
  gcloud run services proxy dataplex-business-ui --region=asia-northeast3 --project=YOUR_PROJECT_ID --port=8080
  ```
  Open `http://localhost:8080` (or Cloud Shell Web Preview on port 8080).

#### C. Google OAuth Sign-in Consent
When signing in with Google, ensure you select **"Select all"** or check all requested permission boxes (`Google Cloud Platform`, `BigQuery`, `Dataplex`) on the Google consent screen to ensure full access to metadata and analytics.
