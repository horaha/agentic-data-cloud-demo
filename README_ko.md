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

이 데모는 **Google Cloud Shell**에서 단 한 줄의 명령어로 손쉽게 전체 데모 스택을 기동할 수 있습니다.

### 1단계: 저장소 클론 및 자동 구축 스크립트 실행

구글 클라우드 콘솔에서 Cloud Shell을 열고, 저장소를 클론한 뒤 자동 구축 스크립트(`setup.sh`)를 실행합니다. 스크립트가 현재 활성화된 GCP 프로젝트 ID를 자동으로 감지하여 인프라를 한 번에 빌드합니다.

```bash
git clone https://github.com/horaha/agentic-data-cloud-demo.git
cd agentic-data-cloud-demo

# 활성화된 GCP 프로젝트가 맞는지 확인
gcloud config get-value project

./setup.sh
```

### 2단계: 데이터 분석 및 AI 노트북 실행
인프라 배포가 완료되면, 제공된 주피터 노트북을 통해 실습 시나리오를 가동합니다.
* 로컬 파이썬 개발 환경 구성 및 개별 노트북에 대한 세부 설명은 [분석 가이드 문서](analytics/README_ko.md)를 참고하세요.
* 테라폼으로 함께 구축된 **Colab Enterprise** 템플릿 환경에 노트북을 업로드하여 곧바로 웹 브라우저 상에서 실습할 수도 있습니다.


## 라이선스
이 프로젝트는 Apache 2.0 라이선스를 따릅니다.
