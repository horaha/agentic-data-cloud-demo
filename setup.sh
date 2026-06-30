#!/bin/bash

# ==============================================================================
# Agentic Data Cloud Demo - GCP Infrastructure Auto Setup Script
# ==============================================================================

set -e # 에러 발생 시 즉시 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 색상 초기화

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}  Agentic Data Cloud Demo 인프라 자동 구축 스크립트를 시작합니다.    ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# 1. Active GCP 프로젝트 조회
echo -e "\n${YELLOW}[1단계] 활성화된 Google Cloud 프로젝트를 감지하는 중...${NC}"
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}[ERROR] 활성화된 GCP 프로젝트 ID를 찾을 수 없습니다.${NC}"
    echo -e "다음 명령어로 프로젝트를 활성화한 뒤 다시 스크립트를 실행해 주세요:"
    echo -e "  gcloud config set project [YOUR_PROJECT_ID]"
    exit 1
fi

echo -e "감지된 GCP 프로젝트 ID: ${GREEN}$PROJECT_ID${NC}"

# 2. 테라폼 설치 여부 검증
echo -e "\n${YELLOW}[2단계] Terraform CLI 가용 여부를 체크하는 중...${NC}"
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}[ERROR] terraform 명령어를 찾을 수 없습니다.${NC}"
    echo -e "Cloud Shell을 사용하거나, 로컬 환경에 Terraform을 설치한 뒤 실행해 주세요."
    exit 1
fi
echo -e "Terraform 가용 여부: ${GREEN}OK${NC}"

# 3. terraform.tfvars 자동 생성 및 프로젝트 ID 설정
echo -e "\n${YELLOW}[3단계] 테라폼 환경 변수 파일(terraform.tfvars) 설정 중...${NC}"
TF_DIR="terraform/infra"

if [ ! -d "$TF_DIR" ]; then
    echo -e "${RED}[ERROR] 테라폼 인프라 디렉토리($TF_DIR)를 찾을 수 없습니다.${NC}"
    exit 1
fi

# terraform.tfvars 생성
cat <<EOF > "$TF_DIR/terraform.tfvars"
project_id = "$PROJECT_ID"
region     = "asia-northeast3"
EOF

echo -e "${GREEN}terraform.tfvars 생성 및 설정 완료!${NC} (Project ID: $PROJECT_ID, Region: asia-northeast3)"

# 4. 테라폼 빌드 가동
echo -e "\n${YELLOW}[4단계] 테라폼 초기화(Terraform Init) 실행 중...${NC}"
cd "$TF_DIR"
terraform init

echo -e "\n${YELLOW}[5단계] 테라폼 리소스 생성(Terraform Apply) 시작...${NC}"
echo -e "${BLUE}※주의: API 활성화 및 리소스 구성에 약 3~5분 정도 소요될 수 있습니다.${NC}"
terraform apply -auto-approve

# 5. 구축 완료 안내 및 요약 정보 출력
echo -e "\n${GREEN}======================================================================${NC}"
echo -e "${GREEN}  인프라 구축이 완료되었습니다! 아래 생성 정보 요약을 참고하세요.   ${NC}"
echo -e GREEN="======================================================================"

echo -e "\n${YELLOW}--- [구축된 주요 리소스 요약] ---${NC}"
terraform output

echo -e "\n${YELLOW}--- [다음 실습 단계 안내] ---${NC}"
echo -e "1. ${BLUE}analytics/notebooks/${NC} 디렉토리로 이동합니다."
echo -e "2. ${GREEN}01_data_profile_quality.ipynb${NC} 노트북을 실행하여 순차적으로 데모 실습을 시작합니다."
echo -e "3. 주피터 환경 실행 전에 active python env가 설정되어 있는지 확인하세요."
echo -e "======================================================================"
cd - > /dev/null
