# 5. BigQuery 복제 설정
data "google_project" "project" {
  depends_on = [module.apis]
}

# API 활성화 후 서비스 에이전트 전파를 위해 추가 대기 처리 (10초)
resource "time_sleep" "wait_for_service_agents" {
  depends_on = [module.apis]

  create_duration = "10s"
}

# BigQuery Data Transfer service agent 권한 부여 (403 방지를 위해 주석 처리)
# resource "google_project_iam_member" "bqp_dts_permissions" {
#   project = var.project_id
#   role    = "roles/iam.serviceAccountTokenCreator"
#   member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
# 
#   depends_on = [time_sleep.wait_for_service_agents]
# }

# 임시 서비스 계정에 대해 DTS 서비스 에이전트의 Token Creator 권한 부여 (우회 리소스)
resource "google_service_account_iam_member" "qwiklabs_sa_dts_impersonation" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${data.google_project.project.project_id}@${data.google_project.project.project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"

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
  depends_on = [google_service_account_iam_member.qwiklabs_sa_dts_impersonation, google_bigquery_dataset.thelook]

  display_name           = "Replicate thelook_ecommerce to Seoul"
  location               = var.region
  data_source_id         = "cross_region_copy"
  schedule               = "every 24 hours"
  destination_dataset_id = google_bigquery_dataset.thelook.dataset_id

  service_account_name = "${data.google_project.project.project_id}@${data.google_project.project.project_id}.iam.gserviceaccount.com"

  params = {
    source_dataset_id           = "thelook_ecommerce"
    source_project_id           = "bigquery-public-data"
    overwrite_destination_table = "true"
  }
}

# Dataplex Service Agent에 빅쿼리 데이터 편집자(BigQuery Data Editor) 권한 부여 (403 방지를 위해 주석 처리)
# resource "google_project_iam_member" "dataplex_bigquery_editor" {
#   project = var.project_id
#   role    = "roles/bigquery.dataEditor"
#   member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dataplex.iam.gserviceaccount.com"
# 
#   depends_on = [time_sleep.wait_for_service_agents]
# }
