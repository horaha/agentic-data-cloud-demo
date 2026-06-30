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
