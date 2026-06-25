provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. API 활성화
module "apis" {
  source = "../modules/api"

  project_id = var.project_id
  apis = [
    # Compute Engine (VM 및 기본 네트워크 구성)
    "compute.googleapis.com",
    # IAM (서비스 계정 및 권한 관리)
    "iam.googleapis.com",
    # Vertex AI (머신러닝 모델 및 파이프라인)
    "aiplatform.googleapis.com",
    # App Hub (GCP 자원 기반 애플리케이션 구조 정의)
    "apphub.googleapis.com",
    # Identity-Aware Proxy (보안 터널링 및 액세스 제어)
    "iap.googleapis.com",
    # Vertex AI Workbench (Jupyter 노트북 환경)
    "notebooks.googleapis.com",
    # 네트워크 보안 구성 (TLS, 인증서 등)
    "networksecurity.googleapis.com",
    # 네트워크 서비스 관리 (로드 밸런서 등)
    "networkservices.googleapis.com",
    # Security Command Center (보안 취약점 및 위협 탐지)
    "securitycenter.googleapis.com",
    # Text-to-Speech (음성 합성 서비스)
    "texttospeech.googleapis.com",
    # API Hub (API 검색 및 거버넌스)
    "apihub.googleapis.com",
    # Cloud API 레지스트리 (API 관리)
    "cloudapiregistry.googleapis.com",
    # Agent Registry (AI 에이전트 및 연동 툴 관리)
    "agentregistry.googleapis.com",
    # Model Armor (LLM 가드레일 및 필터링)
    "modelarmor.googleapis.com",
    # Cloud Observability (시스템 모니터링 및 로깅 통합)
    "observability.googleapis.com",
    # App Topology (애플리케이션 자원 간 연결 상태 시각화)
    "apptopology.googleapis.com",
    # SaaS 서비스 매니지먼트 (SaaS 솔루션 통합 제어)
    "saasservicemgmt.googleapis.com",
    # IAM 커넥터 (외부 시스템 보안 연동 지원)
    "iamconnectors.googleapis.com",
    # 원격 측정 분석 데이터 수집
    "telemetry.googleapis.com",
    # Cloud Trace (애플리케이션 지연 시간 분석)
    "cloudtrace.googleapis.com",
    # Dataform (BigQuery SQL ELT 파이프라인 관리)
    "dataform.googleapis.com",
    # Cloud Logging (로그 데이터 수집 및 분석)
    "logging.googleapis.com",
    # Cloud Monitoring (대시보드 및 경보)
    "monitoring.googleapis.com",
    # Cloud Storage (객체 스토리지, 백업 및 ML 모델 저장)
    "storage.googleapis.com",
    # BigQuery Data Transfer Service (외부 데이터 소스 자동 적재)
    "bigquerydatatransfer.googleapis.com",
    # Data Catalog (메타데이터 중앙 검색)
    "datacatalog.googleapis.com",
    # Dataplex (데이터 거버넌스, 데이터 프로파일 및 품질 스캔)
    "dataplex.googleapis.com",
    # Data Lineage (데이터 가공 이력 추적)
    "datalineage.googleapis.com",
    # Gemini Cloud Assist / AI Companion 기능 활성화 (코드 어시스턴트 등)
    "cloudaicompanion.googleapis.com",
    # BigQuery Studio 내 Gemini 통합 및 AI Insights 기능 활성화
    "bigqueryunified.googleapis.com",
    # BigQuery Data Analytics Gemini API 활성화
    "geminidataanalytics.googleapis.com"
  ]
}

# 2. VPC 생성
module "vpc" {
  source = "../modules/vpc"

  project_id            = var.project_id
  network_name          = "adc-demo-vpc"
  public_subnet_name    = "adc-demo-public-subnet-asne3"
  public_ip_cidr_range  = "10.0.0.0/24"
  private_subnet_name   = "adc-demo-private-subnet-asne3"
  private_ip_cidr_range = "10.0.100.0/24"
  region                = var.region

  depends_on = [module.apis]
}

resource "google_compute_subnetwork" "private_subnet_usce1" {
  name                     = "adc-demo-private-subnet-usce1"
  ip_cidr_range            = "10.0.101.0/24"
  region                   = "us-central1"
  network                  = module.vpc.network_id
  project                  = var.project_id
  private_ip_google_access = true

  depends_on = [module.apis]
}

# 3. IAM 생성
module "iam" {
  source = "../modules/iam"

  project_id   = var.project_id
  account_id   = "playground-sa"
  display_name = "Playground Service Account"
  roles        = ["roles/viewer"]

  depends_on = [module.apis]
}

# 4. GCS 버킷 생성 및 리소스 파일 업로드
module "resource_bucket" {
  source = "../modules/gcs"

  project_id    = var.project_id
  bucket_name   = "metadata-resources-${var.project_id}"
  location      = var.region
  storage_class = "STANDARD"
  force_destroy = true

  depends_on = [module.apis]
}

# 비즈니스 용어집 JSON 파일 업로드
resource "google_storage_bucket_object" "business_glossary" {
  name   = "resources/business_glossary.json"
  source = "../../analytics/resources/business_glossary.json"
  bucket = "metadata-resources-${var.project_id}"

  depends_on = [module.resource_bucket]
}

# 그래프 비즈니스 용어집 JSON 파일 업로드
resource "google_storage_bucket_object" "business_glossary_graph" {
  name   = "resources/business_glossary_graph.json"
  source = "../../analytics/resources/business_glossary_graph.json"
  bucket = "metadata-resources-${var.project_id}"

  depends_on = [module.resource_bucket]
}

# SQL 매핑 Aspect 스키마 JSON 파일 업로드
resource "google_storage_bucket_object" "aspect_sql_mapping" {
  name   = "resources/aspect_sql_mapping.json"
  source = "../../analytics/resources/aspect_sql_mapping.json"
  bucket = "metadata-resources-${var.project_id}"

  depends_on = [module.resource_bucket]
}

# 그래프 매핑 Aspect 스키마 JSON 파일 업로드
resource "google_storage_bucket_object" "aspect_graph_mapping" {
  name   = "resources/aspect_graph_mapping.json"
  source = "../../analytics/resources/aspect_graph_mapping.json"
  bucket = "metadata-resources-${var.project_id}"

  depends_on = [module.resource_bucket]
}

# 5. BigQuery 복제 설정
data "google_project" "project" {
  depends_on = [module.apis]
}

# BigQuery Data Transfer service agent 권한 부여
resource "google_project_iam_member" "bqp_dts_permissions" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"

  depends_on = [module.apis]
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

# 6. Colab Enterprise 런타임 템플릿 생성
resource "google_colab_runtime_template" "colab_template_asne3" {
  name         = "adc-demo-template-asne3"
  display_name = "Colab Runtime Template (Seoul)"
  location     = var.region
  description  = "Colab Enterprise Runtime Template in asia-northeast3"

  machine_spec {
    machine_type = "e2-standard-4"
  }

  network_spec {
    enable_internet_access = true
    network                = module.vpc.network_id
    subnetwork             = module.vpc.private_subnet_id
  }

  depends_on = [module.vpc, module.apis]
}
