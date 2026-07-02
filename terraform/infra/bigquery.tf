# 5. BigQuery 복제 설정
data "google_project" "project" {
  depends_on = [module.apis]
}

# API 활성화 후 서비스 에이전트 전파를 위해 추가 대기 처리 (10초)
resource "time_sleep" "wait_for_service_agents" {
  depends_on = [module.apis]

  create_duration = "10s"
}

# BigQuery Data Transfer service agent 권한 부여 (Qwiklabs 환경 우회를 위해 주석 처리)
# US 멀티 리전 내 복제(Colocated Copy)의 경우 토큰 생성자 권한이 요구되지 않으므로 제거 가능합니다.
# resource "google_project_iam_member" "bqp_dts_permissions" {
#   project = var.project_id
#   role    = "roles/iam.serviceAccountTokenCreator"
#   member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
# 
#   depends_on = [time_sleep.wait_for_service_agents]
# }


# 대상 데이터셋 생성
resource "google_bigquery_dataset" "thelook" {
  dataset_id                  = "thelook_ecommerce"
  friendly_name               = "TheLook eCommerce"
  description                 = "Cloned public dataset thelook_ecommerce"
  location                    = "US" # "US" 멀티 리전으로 설정하여 cross-region 복제 요건을 제거
  default_table_expiration_ms = null

  depends_on = [module.apis]
}


# Dataplex Service Agent에 빅쿼리 데이터 편집자(BigQuery Data Editor) 권한 부여
# Qwiklabs의 프로젝트 수준 IAM 제한을 피하기 위해 데이터셋 수준 권한(google_bigquery_dataset_iam_member)으로 변경합니다.
# 만약 이 설정도 Qwiklabs 조직 정책 도메인 제한으로 인해 실패할 경우, 이 리소스 전체를 주석 처리해 주세요.
resource "google_bigquery_dataset_iam_member" "dataplex_bigquery_editor" {
  dataset_id = google_bigquery_dataset.thelook.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dataplex.iam.gserviceaccount.com"

  depends_on = [time_sleep.wait_for_service_agents]
}

