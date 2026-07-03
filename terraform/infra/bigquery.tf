# 5. BigQuery 설정 및 데이터셋 생성
data "google_project" "project" {
  depends_on = [module.apis]
}

# API 활성화 후 서비스 에이전트 전파를 위해 추가 대기 처리 (10초)
resource "time_sleep" "wait_for_service_agents" {
  depends_on = [module.apis]

  create_duration = "10s"
}

# 대상 데이터셋 생성
resource "google_bigquery_dataset" "thelook" {
  dataset_id                  = "thelook_ecommerce"
  friendly_name               = "TheLook eCommerce"
  description                 = "Cloned public dataset thelook_ecommerce"
  location                    = var.region
  default_table_expiration_ms = null

  depends_on = [module.apis]
}

# Dataplex Service Agent에 빅쿼리 데이터 편집자(BigQuery Data Editor) 권한 부여
resource "google_bigquery_dataset_iam_member" "dataplex_bigquery_editor" {
  dataset_id = google_bigquery_dataset.thelook.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dataplex.iam.gserviceaccount.com"

  depends_on = [time_sleep.wait_for_service_agents]
}

# BigQuery 원격 연결(Remote Connection) 생성 (Vertex AI 연동용)
resource "google_bigquery_connection" "vertex_connection" {
  connection_id = "vertex-connection"
  project       = var.project_id
  location      = var.region
  friendly_name = "Vertex AI Connection"
  description   = "Connection to Vertex AI for remote models"
  cloud_resource {}

  depends_on = [module.apis]
}

# Vertex AI 사용 권한을 BigQuery 원격 연결 서비스 계정에 부여
resource "google_project_iam_member" "vertex_connection_aiplatform_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_bigquery_connection.vertex_connection.cloud_resource[0].service_account_id}"
}



