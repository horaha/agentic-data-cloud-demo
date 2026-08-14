# Knowledge Catalog Business Interface - 1.4.0 (한글 가이드)

BigQuery 고객의 비즈니스 사용자가 **Knowledge Catalog** (구 Dataplex Universal Catalog)의 데이터 자산을 손쉽게 탐색하고 접근할 수 있도록 지원하는 오픈소스 웹 애플리케이션입니다.

## 주요 목적
- 비즈니스 사용자가 스스로 필요한 데이터를 탐색할 수 있도록 지원
- **Knowledge Catalog** API를 활용한 데이터 접근 요청 프로세스 간소화
- 데이터 접근 요청 이력을 통한 데이터 거버넌스 및 준수성 향상
- 데이터 발견 가능성 확대를 통한 데이터 문해력(Data Literacy) 증대
- 향후 데이터 거버넌스 기능 확장을 위한 맞춤형 플랫폼 제공

## 주요 대상 사용자
- Knowledge Catalog 데이터를 검색하고 이해해야 하는 비즈니스 사용자 및 데이터 분석가
- 데이터 스튜어드 (Data Stewards)

---

## 주요 기능
- **안전한 구글 소셜 로그인**: `@react-oauth/google`을 활용한 간편한 구글 OAuth 2.0 로그인
- **보호된 라우트**: 미인증 사용자의 접근을 차단하고 로그인 페이지로 자동 이동
- **최신 기술 스택**: Vite, TypeScript, Material UI (M3 Design Token 적용)
- **GCP API 권한 검증**: 로그인 후 사용자 계정이 Knowledge Catalog 데이터 접근 권한을 보유했는지 자동 검증
- **필터 기반 검색**: 도메인, 태그, 프로젝트 등 다양한 필터로 데이터셋 검색
- **비즈니스 용어집(Glossary) 탐색**: 용어집, 카테고리, 용어 계층 구조 탐색
- **데이터셋 세부 정보 확인**: Asset 이름, 설명, Schema, BigQuery 테이블 쿼리 및 파이프라인 데이터 확인

---

## 시작하기: 로컬 환경 실행

### 사전 요구사항
- Node.js (v20 이상)
- 활성화된 Google Cloud 프로젝트

### 1단계: 저장소 클론 및 패키지 설치
```bash
git clone https://github.com/horaha/agentic-data-cloud-demo.git
cd agentic-data-cloud-demo/business-ui
npm install
```

### 2단계: Google OAuth Client ID 설정
1. [Google Cloud Console Credentials](https://console.cloud.google.com/apis/credentials) 페이지로 이동합니다.
2. **+ 사용자 인증 정보 만들기 ➔ OAuth 클라이언트 ID**를 선택합니다.
3. 애플리케이션 유형으로 **웹 애플리케이션**을 선택합니다.
4. **승인된 JavaScript 원본(Authorized origins)**:
   - `http://localhost:5173` (로컬 Vite dev 서버)
   - `http://localhost:8080` (백엔드 / 프록시)
5. **승인된 리디렉션 URI(Authorized redirect URIs)**:
   - `http://localhost:5173`
   - `http://localhost:8080/auth/google/callback`
6. 생성된 **Client ID**를 복사합니다.

### 3단계: 환경 변수 설정
`business-ui/.env` 파일을 생성하거나 수정하고 Client ID를 붙여넣습니다:
```shell
VITE_GOOGLE_CLIENT_ID="YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"
VITE_API_URL="/api"
VITE_API_VERSION="v1"
```

### 4단계: 애플리케이션 실행
```bash
# 프론트엔드 실행 (포트 5173)
npm run dev

# 백엔드 실행 (포트 8080)
node backend/server.js
```
브라우저에서 `http://localhost:5173` 또는 Cloud Shell 웹 미리보기(8080)로 접속합니다.

---

## Cloud Run 자동 배포

테라폼 및 원클릭 자동 배포 스크립트를 사용하여 Cloud Run 환경에 간편하게 배포할 수 있습니다. 자세한 가이드는 [UI 한글 배포 가이드](README.deploy_ko.md)를 참고하세요.

```bash
cd business-ui
./deploy.sh
```

### 접속 및 구글 로그인 권한 안내
1. **서비스 직접 접속**:
   `deploy.sh` 실행 시 IAM 호출 권한(`allUsers` 또는 활성 계정 권한)이 자동 설정되므로, 터미널에 출력된 **Service URL** (예: `https://dataplex-business-ui-xxxx.run.app`)로 웹 브라우저에서 직접 접속합니다. (별도의 프록시 연결이 필요하지 않습니다.)

2. **구글 로그인 권한 동의**:
   로그인 팝업창이 나타날 때 **"모두 선택(Select all)"** 또는 `Google Cloud Platform`, `BigQuery`, `Dataplex` 체크박스를 모두 **체크(v)** 하신 후 [계속]을 클릭하셔야 메타데이터 탐색 권한이 정상 부여됩니다.
