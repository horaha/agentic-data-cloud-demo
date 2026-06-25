# Agentic Data Cloud Demo

이 저장소는 Google Cloud 상에 AI 대응 데이터 클라우드 인프라를 구축하고, Gemini와 BigQuery를 활용한 고급 데이터 분석 및 에이전트 연동을 실습하는 **Agentic Data Cloud 데모**용 코드와 설정을 담고 있습니다.

## 저장소 구조

프로젝트는 크게 두 가지 핵심 영역으로 구분되어 있습니다.

```text
.
├── terraform/                # GCP 리소스 프로비저닝을 위한 테라폼 코드
│   ├── modules/              # 재사용 가능한 테라폼 모듈 (API, VPC, GCS, IAM)
│   └── infra/                # 전체 데모 스택을 배포하기 위한 통합 루트 모듈
│
└── analytics/                # Python 및 Jupyter 노트북을 활용한 데이터 분석 및 AI 실습
    ├── notebooks/            # 데이터 품질, 카탈로그, 그래프, AI 연동을 위한 대화형 노트북
    ├── resources/            # 비즈니스 용어집 및 물리 스키마 매핑 정의 파일
    └── pyproject.toml        # 현대적인 파이썬 의존성 관리 설정 (uv 사용)
```

## 시작 가이드

데모를 실행하려면 다음 두 단계를 순서대로 진행해 주세요.

### 1단계: 인프라 프로비저닝 (GCP 리소스 구축)
테라폼을 사용해 필요한 GCP 리소스(API 활성화, VPC 네트워크, BigQuery 데이터셋, GCS 버킷, IAM 권한, Colab 템플릿 등)를 한 번에 생성합니다.
* 자세한 배포 방법은 [테라폼 안내 문서](terraform/README.ko.md)를 참고하세요.

```bash
cd terraform/infra
# 환경 설정 복사 및 수정
cp terraform.tfvars.example terraform.tfvars
# 배포 실행
terraform init
terraform apply
```

### 2단계: 데이터 분석 및 AI 노트북 실행
인프라 배포가 완료되면, 제공된 주피터 노트북을 통해 다양한 시나리오 실습을 진행합니다.
* 패키지 설치 및 노트북에 대한 자세한 내용은 [분석 가이드 문서](analytics/README_ko.md)를 참고하세요.

```bash
cd analytics
# uv를 사용한 의존성 동기화
uv sync
# Jupyter Notebook 실행 또는 Vertex AI Workbench / Colab Enterprise에 노트북 업로드 후 실행
```

## 라이선스
이 프로젝트는 Apache 2.0 라이선스를 따릅니다.
