# 1. API 활성화
module "apis" {
  source = "../modules/api"

  project_id = var.project_id
  apis = [
    # Cloud Resource Manager (테라폼 API 관리를 위해 필수)
    "cloudresourcemanager.googleapis.com",
    # Compute Engine (기본 네트워크 및 인프라 구성)
    "compute.googleapis.com",
    # IAM (서비스 계정 및 권한 관리)
    "iam.googleapis.com",
    # Vertex AI (머신러닝 모델 및 AI Companion 기능의 기반)
    "aiplatform.googleapis.com",
    # Vertex AI Workbench (실습용 Jupyter 노트북 환경)
    "notebooks.googleapis.com",
    # Cloud Logging (로그 데이터 수집 및 분석)
    "logging.googleapis.com",
    # Cloud Monitoring (대시보드 및 모니터링)
    "monitoring.googleapis.com",
    # Cloud Storage (객체 스토리지, 백업 및 데이터 적재)
    "storage.googleapis.com",
    # BigQuery Data Transfer Service (외부 데이터 소스 자동 적재)
    "bigquerydatatransfer.googleapis.com",
    # Data Catalog (메타데이터 중앙 검색 - Knowledge Catalog 필수)
    "datacatalog.googleapis.com",
    # Dataplex (데이터 거버넌스, 데이터 프로파일 및 품질 스캔)
    "dataplex.googleapis.com",
    # Data Lineage (데이터 가공 이력 추적)
    "datalineage.googleapis.com",
    # Gemini Cloud Assist / AI Companion 기능 활성화 (코드 어시스턴트 등)
    "cloudaicompanion.googleapis.com",
    # BigQuery Studio 내 Gemini 통합 및 AI Insights 기능 활성화
    "bigqueryunified.googleapis.com",
    # BigQuery Data Analytics Gemini API 활성화 (BigQuery Conversational Analytics 필수)
    "geminidataanalytics.googleapis.com"
  ]
}
