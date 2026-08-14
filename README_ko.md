# Agentic Data Cloud Demo

이 저장소는 Google Cloud 상에 AI 대응 데이터 클라우드 인프라를 구축하고, Gemini와 BigQuery를 활용한 고급 데이터 분석 및 에이전트 연동을 실습하는 **Agentic Data Cloud 데모**용 코드와 설정을 담고 있습니다.

## 저장소 구조

프로젝트는 크게 두 가지 핵심 영역으로 구분되어 있습니다.

```text
.
├── terraform/                # GCP 리소스 프로비저닝을 위한 테라폼 코드
│   ├── modules/              # 재사용 가능한 테라폼 모듈 (API, VPC, GCS, IAM)
│   └── infra/                # 전체 데모 스택을 배포하기 위한 통합 루트 모듈 (UI 자원 포함)
│
├── analytics/                # Python 및 Jupyter 노트북을 활용한 데이터 분석 및 AI 실습
│   ├── notebooks/            # 데이터 품질, 카탈로그, 그래프, AI 연동을 위한 대화형 노트북
│   ├── resources/            # 비즈니스 용어집 및 물리 스키마 매핑 정의 파일
│   └── pyproject.toml        # 현대적인 파이썬 의존성 관리 설정 (uv 사용)
│
└── business-ui/              # 비즈니스 사용자를 위한 React/Express 웹 애플리케이션 (Dataplex UI)
    ├── src/                  # React 프론트엔드 소스 코드 (Material UI, Redux Toolkit)
    ├── backend/              # Node.js 백엔드 서버 코드 (Express, Dataplex 연동 API)
    ├── deploy.sh             # Cloud Run 빌드 및 원클릭 배포 자동화 스크립트
    └── README.deploy.md      # Cloud Run 배포를 위한 가이드 문서
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

### 3단계: 비즈니스 UI(웹 인터페이스) Cloud Run 자동 배포 (선택 사항)
**Business UI (선택 사항)**는 비즈니스 도메인 사용자용 자산 검색 및 메타데이터 탐색 화면을 제공하며, 필요 시 Cloud Run 환경에 원클릭으로 자동 배포할 수 있습니다.

#### 1. Google OAuth Client ID 생성 및 설정 (필수 1회)
1. [GCP Console Credentials](https://console.cloud.google.com/apis/credentials) ➔ **+ 사용자 인증 정보 만들기 ➔ OAuth 클라이언트 ID** (웹 애플리케이션 유형)를 선택합니다.
2. **승인된 JavaScript 원본**: `http://localhost:8080`
3. **승인된 리디렉션 URI**: `http://localhost:8080/auth/google/callback`
4. 발급받은 Client ID를 `terraform/infra/terraform.tfvars` 파일에 작성합니다:
   ```hcl
   oauth_client_id = "YOUR_OAUTH_CLIENT_ID.apps.googleusercontent.com"
   ```

#### 2. Cloud Run 원클릭 자동 배포
```shell
cd business-ui
./deploy.sh
```
*(자세한 배포 동작 원리는 [UI 한글 배포 가이드](business-ui/README.deploy_ko.md)를 참고하세요.)*

#### 3. 접속 및 구글 로그인 권한 동의
* **프록시 접속 (조직 보안 정책 적용 시):** GCP 조직 정책(Domain Restricted Sharing)으로 인해 Cloud Run URL 직접 접속 시 `403 Forbidden`이 발생하는 경우, 터미널에서 아래 프록시 명령어로 접속합니다:
  ```shell
  gcloud run services proxy dataplex-business-ui --region=asia-northeast3 --project=YOUR_PROJECT_ID --port=8080
  ```
  (실행 후 `http://localhost:8080` 또는 Cloud Shell Web Preview 8080 포트로 접속)
* **구글 로그인 권한 동의:** 로그인 팝업창이 나타날 때 **"모두 선택(Select all)"** 또는 `Google Cloud Platform`, `BigQuery`, `Dataplex` 체크박스를 모두 **체크(v)** 하신 후 [계속]을 클릭하셔야 메타데이터 탐색 권한이 정상 부여됩니다.

## 라이선스
이 프로젝트는 Apache 2.0 라이선스를 따릅니다.
