# 테라폼을 활용한 Cloud Run 자동 배포 가이드

본 가이드는 루트 테라폼(Terraform) 설정 및 Cloud Build를 이용하여 **Knowledge Catalog Business Interface** 웹 애플리케이션을 Google Cloud Run 환경에 원클릭으로 빌드 및 배포하는 절차를 설명합니다.

## 디렉터리 구성
- `terraform/infra/business_ui.tf`: Artifact Registry 저장소, Cloud Run v2 서비스 및 IAM 호출 권한 설정
- `business-ui/deploy.sh`: 환경 검증, Artifact Registry 자동 임포트, Cloud Build 컨테이너 빌드 및 Cloud Run 배포 자동화 스크립트

---

## 배포 절차

### 1. 사전 준비 사항
- Google Cloud SDK (`gcloud` CLI) 설치 및 인증
- `gcloud` CLI 및 Application Default Credentials (ADC) 로그인 수행 및 활성 프로젝트 설정:
  ```shell
  gcloud auth login
  gcloud auth application-default login
  gcloud config set project YOUR_PROJECT_ID
  ```
- 대상 GCP 프로젝트의 결제(Billing)가 활성화되어 있는지 확인합니다.

### 2. 변수 설정 (`terraform.tfvars`)
배포 스크립트는 현재 활성화된 GCP 프로젝트 ID와 로그인 계정을 자동으로 감지합니다. OAuth Client ID 설정을 위해 필요 시 `terraform.tfvars`를 수정합니다:
```shell
nano ../terraform/infra/terraform.tfvars
```

```hcl
project_id      = "YOUR_PROJECT_ID"
region          = "asia-northeast3"
oauth_client_id = "YOUR_OAUTH_CLIENT_ID.apps.googleusercontent.com"
admin_email     = "your-admin-email@example.com"
```

### 3. 배포 스크립트 실행
`business-ui` 디렉터리에서 `deploy.sh` 스크립트를 실행합니다:
```shell
./deploy.sh
```

스크립트가 수행하는 작업:
1. `gcloud` 프로젝트 ID 및 Application Default Credentials (ADC) 정상 동작 여부 검증
2. 프로젝트 변경 시 `terraform.tfvars` 자동 동기화 및 이전 캐시 상태 리셋
3. 이미 존재하는 Artifact Registry(`dataplex-ui-repo`) 및 Cloud Run 서비스(`dataplex-business-ui`)의 `terraform import` 자동 처리 (409 Conflict 에러 예방)
4. Cloud Build를 통한 도커 컨테이너 이미지 빌드 및 Artifact Registry 푸시
5. Cloud Run v2 서비스 배포 및 라이브 서비스 URL 출력

---

### 4. 배포 후 설정 및 접속 가이드

#### 가. Google OAuth 승인된 원본 설정
배포 완료 후 출력되는 **Service URL** (또는 프록시 URL `http://localhost:8080`)을 Google Cloud Console Credentials 페이지에 추가합니다:
1. **Google Cloud Console ➔ APIs & Services ➔ Credentials (사용자 인증 정보)** 페이지로 이동합니다.
2. 사용 중인 Web Client를 클릭합니다.
3. **승인된 JavaScript 원본 (Authorized JavaScript origins)**:
   - `http://localhost:8080` (또는 콘솔에 출력된 Cloud Run URL 예: `https://dataplex-business-ui-xxxx.run.app`)
4. **승인된 리디렉션 URI (Authorized redirect URIs)**:
   - `http://localhost:8080/auth/google/callback` (또는 콘솔에 출력된 리디렉션 URL 예: `https://dataplex-business-ui-xxxx.run.app/auth/google/callback`)
5. **저장**을 클릭합니다.

#### 나. 서비스 접속 방법
- **직접 접속**: 조직 정책상 `allUsers` 공개 접근이 허용된 경우 Cloud Run URL로 직접 접속합니다.
- **프록시 접속 (GCP 조직 보안 정책 적용 시)**:
  도메인 제한 공유(Domain Restricted Sharing) 보안 정책으로 인해 `403 Forbidden` 에러가 발생하는 경우 터미널에서 프록시 명령어를 실행하여 접속합니다:
  ```shell
  gcloud run services proxy dataplex-business-ui --region=asia-northeast3 --project=YOUR_PROJECT_ID --port=8080
  ```
  실행 후 브라우저에서 `http://localhost:8080` (또는 Cloud Shell 우측 상단 Web Preview 8080 포트)로 접속합니다.

#### 다. 구글 로그인 권한 동의
구글 로그인 동의 팝업창이 나타날 때 **"모두 선택(Select all)"** 또는 `Google Cloud Platform`, `BigQuery`, `Dataplex` 체크박스를 모두 **체크(v)** 하신 후 [계속]을 클릭하셔야 메타데이터 탐색 권한이 정상 부여됩니다.
