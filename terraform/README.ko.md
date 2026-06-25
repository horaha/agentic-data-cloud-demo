# 테라폼을 사용한 GCP 인프라 프로비저닝

이 저장소는 Agentic Data Cloud 데모를 위한 GCP 인프라 리소스를 관리하도록 설계되었습니다.

## 디렉토리 구조

가독성을 높이고 관리를 원활하게 하기 위해 **중앙 집중식 모듈 관리** 및 **단일 프로젝트 배포** 구조로 통합 개편되었습니다.

```text
.
├── modules/                  # 공통으로 사용할 재사용 가능한 모듈들
│   ├── api/                  # GCP API 활성화 모듈
│   ├── vpc/                  # VPC 및 서브넷 생성 모듈
│   ├── iam/                  # IAM 서비스 계정 및 역할(Role) 관리 모듈
│   └── gcs/                  # Cloud Storage 버킷 생성 모듈
│
└── infra/                    # 통합 인프라 정의 디렉토리
    ├── main.tf               # 모든 리소스 정의 (APIs, VPC, GCS, BigQuery, IAM, Colab)
    ├── variables.tf          # 전역 변수 정의
    ├── outputs.tf            # 통합 출력값 정의 (주로 VPC 리소스 정보)
    ├── versions.tf           # 테라폼 및 GCS 백엔드 구성
    └── terraform.tfvars      # 사용자 정의 변수 값 설정 (project_id, region)
```

### 주요 개선 사항
1. **간소화된 배포**: 모든 인프라 리소스가 `infra/` 폴더 아래로 통합되었습니다. 이제 단 한 번의 `terraform apply` 명령으로 전체 인프라를 구축할 수 있습니다.
2. **간소화된 의존성 관리**: 이전 버전에서 사용하던 `terraform_remote_state` 데이터 소스 방식 대신, `main.tf` 파일 내부에서 리소스 간 의존성(예: Colab 템플릿의 VPC 서브넷 참조)을 직접 처리하도록 개선하여 복잡성을 줄였습니다.
3. **로컬 재사용 모듈 내재화**: 기존에 외부에서 참조하던 공통 테라폼 모듈들을 저장소 내부 `terraform/modules/` 경로로 복사하여 프로젝트 내 독립성을 확보했습니다.

## 초기 설정: 테라폼 State 버킷 생성

이 단계는 프로젝트당 1회만 수행하면 됩니다. 테라폼을 실행하기 전에 변경 사항 상태를 안전하게 관리하기 위해 상태(State) 파일을 원격에 저장할 GCS 버킷을 생성합니다.

버킷 명은 `tfstate-<사용자-GCP-프로젝트-ID>-asne3` (예: 서울 리전 `asia-northeast3` 기준 `tfstate-myproject-asne3`) 형식을 권장합니다.

```bash
# 1. 사용할 GCP 프로젝트 ID 설정
gcloud config set project <your-gcp-project-id>

# 2. GCS 버킷 생성
gcloud storage buckets create gs://tfstate-<your-gcp-project-id>-asne3 --location asia-northeast3 --uniform-bucket-level-access
```

> **참고**: 만약 추천 규칙 외 다른 버킷 이름을 사용하려는 경우, `infra/versions.tf` 의 `bucket` 매개변수 값도 함께 변경해야 합니다.

## 실행 방법

모든 리소스 정의 및 의존성이 한 곳으로 통합되었으므로 아래 명령어로 간단히 배포할 수 있습니다.

```bash
cd infra

# 테라폼 초기화 (프로바이더 플러그인 및 로컬 모듈 다운로드)
terraform init

# 리소스 생성 계획 검토
terraform plan

# 인프라 리소스 적용 및 배포
terraform apply
```

## 주의 사항
* 실행하기 전에 `infra/terraform.tfvars.example` 파일을 복사하여 `infra/terraform.tfvars` 파일을 생성하고, `project_id` 및 `region` 변수를 실제 사용하려는 대상 GCP 프로젝트 ID 및 리전명으로 변경해 주세요.
* 상태 파일은 `infra/versions.tf` 에 정의된 대로 **GCS (Google Cloud Storage)** 백엔드 버킷을 사용하여 원격으로 안전하게 저장됩니다.
