# 5. BigQuery 복제 설정
data "google_project" "project" {
  depends_on = [module.apis]
}

# API 활성화 후 서비스 에이전트 자동 생성을 위해 대기 처리 (30초)
resource "time_sleep" "wait_for_service_agents" {
  depends_on = [module.apis]

  create_duration = "30s"
}

# BigQuery Data Transfer service agent 권한 부여
resource "google_project_iam_member" "bqp_dts_permissions" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"

  depends_on = [time_sleep.wait_for_service_agents]
}

# 대상 데이터셋 생성
resource "google_bigquery_dataset" "thelook" {
  dataset_id                  = "thelook_ecommerce"
  friendly_name               = "TheLook eCommerce"
  description                 = "Cloned public dataset thelook_ecommerce in Seoul"
  location                    = var.region
  default_table_expiration_ms = null

  depends_on = [module.apis]
}

# 데이터 복제 구성
resource "google_bigquery_data_transfer_config" "thelook_copy" {
  depends_on = [google_project_iam_member.bqp_dts_permissions, google_bigquery_dataset.thelook]

  display_name           = "Replicate thelook_ecommerce to Seoul"
  location               = var.region
  data_source_id         = "cross_region_copy"
  schedule               = "every 24 hours"
  destination_dataset_id = google_bigquery_dataset.thelook.dataset_id
  params = {
    source_dataset_id           = "thelook_ecommerce"
    source_project_id           = "bigquery-public-data"
    overwrite_destination_table = "true"
  }
}

# Dataplex Service Agent에 빅쿼리 데이터 편집자(BigQuery Data Editor) 권한 부여 (자동 테이블 생성을 위해 필요)
resource "google_project_iam_member" "dataplex_bigquery_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dataplex.iam.gserviceaccount.com"

  depends_on = [time_sleep.wait_for_service_agents]
}
