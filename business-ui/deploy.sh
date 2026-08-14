#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

ORIGINAL_DIR=$(pwd)
trap 'cd "$ORIGINAL_DIR" &>/dev/null' EXIT

# Path to the root terraform configurations
TF_DIR="../terraform/infra"

echo "=== Step 0: Validating GCP Environment & Active Project ==="

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo "[ERROR] GCP Project ID가 설정되어 있지 않습니다. 'gcloud config set project [YOUR_PROJECT_ID]' 실행 후 다시 시도해 주세요."
    exit 1
fi
echo "Active GCP Project ID: $PROJECT_ID"

# Check Application Default Credentials (ADC)
if ! gcloud auth application-default print-access-token &>/dev/null; then
    echo "[안내] ADC(Application Default Credentials) 인증이 없거나 만료되었습니다. 인증을 진행합니다..."
    gcloud auth application-default login
fi

# Enable Cloud Resource Manager API if not enabled
gcloud services enable cloudresourcemanager.googleapis.com --project="$PROJECT_ID" 2>/dev/null || true

USER_EMAIL=$(gcloud config get-value account 2>/dev/null || true)
if [ -z "$USER_EMAIL" ]; then
    USER_EMAIL=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null || true)
fi

PREV_PROJECT_ID=""
PREV_OAUTH_CLIENT_ID=""
PREV_ADMIN_EMAIL=""
PREV_REGION="asia-northeast3"

if [ -f "$TF_DIR/terraform.tfvars" ]; then
    PREV_PROJECT_ID=$(sed -n 's/project_id[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' "$TF_DIR/terraform.tfvars" | tr -d ' ' 2>/dev/null || true)
    PREV_OAUTH_CLIENT_ID=$(sed -n 's/oauth_client_id[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' "$TF_DIR/terraform.tfvars" | tr -d ' ' 2>/dev/null || true)
    PREV_ADMIN_EMAIL=$(sed -n 's/admin_email[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' "$TF_DIR/terraform.tfvars" | tr -d ' ' 2>/dev/null || true)
    PREV_REGION_VAL=$(sed -n 's/region[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' "$TF_DIR/terraform.tfvars" | tr -d ' ' 2>/dev/null || true)
    if [ -n "$PREV_REGION_VAL" ]; then PREV_REGION="$PREV_REGION_VAL"; fi
fi

RESET_STATE=false
if [ -n "$PREV_PROJECT_ID" ] && [ "$PREV_PROJECT_ID" != "$PROJECT_ID" ]; then
    RESET_STATE=true
fi
if [ -f "$TF_DIR/terraform.tfstate" ] && ! grep -q "$PROJECT_ID" "$TF_DIR/terraform.tfstate" 2>/dev/null; then
    RESET_STATE=true
fi

if [ "$RESET_STATE" = true ]; then
    echo "[경고] 이전 GCP 프로젝트 설정($PREV_PROJECT_ID)이 현재 활성 프로젝트($PROJECT_ID)와 다릅니다."
    echo "인프라 정합성을 위해 테라폼 캐시 및 상태를 초기화합니다..."
    rm -rf "$TF_DIR/.terraform" "$TF_DIR/terraform.tfstate" "$TF_DIR/terraform.tfstate.backup" "$TF_DIR/.terraform.lock.hcl"
fi

ADMIN_EMAIL="${PREV_ADMIN_EMAIL:-$USER_EMAIL}"

cat <<EOF > "$TF_DIR/terraform.tfvars"
project_id      = "$PROJECT_ID"
region          = "$PREV_REGION"
runtime_user    = "$USER_EMAIL"
admin_email     = "$ADMIN_EMAIL"
oauth_client_id = "$PREV_OAUTH_CLIENT_ID"
EOF

echo "=== Step 1: Initializing and applying Terraform for Artifact Registry ==="
cd "$TF_DIR"
terraform init

# Check if Artifact Registry repository already exists in GCP and import into state if missing
REPO_NAME="dataplex-ui-repo"
if gcloud artifacts repositories describe "$REPO_NAME" --location="$PREV_REGION" --project="$PROJECT_ID" &>/dev/null; then
    if ! terraform state list 2>/dev/null | grep -q "google_artifact_registry_repository.ui_repo"; then
        echo "[안내] GCP 상에 이미 존재하는 Artifact Registry 저장소를 테라폼 상태로 가져옵니다(import)..."
        terraform import google_artifact_registry_repository.ui_repo "projects/${PROJECT_ID}/locations/${PREV_REGION}/repositories/${REPO_NAME}" 2>/dev/null || true
    fi
fi

terraform apply -target=module.apis -target=google_project_iam_member.compute_roles -target=google_artifact_registry_repository.ui_repo -auto-approve

# Get the repository url from Terraform output
REPO_URL=$(terraform output -raw ui_repository_url)

echo "=== Step 2: Submitting Cloud Build for Docker Image ==="
cd "$ORIGINAL_DIR"
STAGING_BUCKET="gs://${PROJECT_ID}-cloudbuild-staging"
gcloud storage buckets create "$STAGING_BUCKET" --location="$PREV_REGION" --project "$PROJECT_ID" 2>/dev/null || true
gcloud builds submit . --gcs-source-staging-dir="${STAGING_BUCKET}/source" --tag "$REPO_URL:latest" --project "$PROJECT_ID"

echo "=== Step 3: Running Terraform and deploying Cloud Run service ==="
cd "$TF_DIR"

# Check if Cloud Run service already exists in GCP and import into state if missing
SERVICE_NAME="dataplex-business-ui"
if gcloud run services describe "$SERVICE_NAME" --region="$PREV_REGION" --project="$PROJECT_ID" &>/dev/null; then
    if ! terraform state list 2>/dev/null | grep -q "google_cloud_run_v2_service.ui_service"; then
        echo "[안내] GCP 상에 이미 존재하는 Cloud Run 서비스를 테라폼 상태로 가져옵니다(import)..."
        terraform import google_cloud_run_v2_service.ui_service "projects/${PROJECT_ID}/locations/${PREV_REGION}/services/${SERVICE_NAME}" 2>/dev/null || true
    fi
fi

terraform apply -target=module.apis -target=google_project_iam_member.compute_roles -target=google_artifact_registry_repository.ui_repo -target=google_cloud_run_v2_service.ui_service -target=google_cloud_run_v2_service_iam_member.allow_unauthenticated -auto-approve
gcloud run deploy dataplex-business-ui --image="$REPO_URL:latest" --region="$PREV_REGION" --project="$PROJECT_ID" --quiet

# Get the final Cloud Run service URL
SERVICE_URL=$(gcloud run services describe dataplex-business-ui --region="$PREV_REGION" --project="$PROJECT_ID" --format="value(status.url)" 2>/dev/null || terraform output -raw ui_service_url)

echo "=========================================================="
echo " Deployment Successful!"
echo " Service URL: $SERVICE_URL"
echo ""
echo " IMPORTANT: Add this URL to your Google Cloud Console OAuth"
echo " Credentials page under Authorized JavaScript origins and"
echo " Redirect URIs (Redirect URI should append /auth/google/callback)"
echo "=========================================================="
