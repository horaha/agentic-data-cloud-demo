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

# Cloud Resource Manager API 사전 활성화 (테라폼 API 관리를 위해 선행 활성화 필수)
echo -e "\n${YELLOW}GCP API 제어를 위해 Cloud Resource Manager API를 사전 활성화합니다...${NC}"
gcloud services enable cloudresourcemanager.googleapis.com --project="$PROJECT_ID"

# API 활성화 전파 대기 (최대 30초)
echo -e "Cloud Resource Manager API 활성화 상태 확인 중..."
for i in {1..15}; do
    if gcloud services list --enabled --project="$PROJECT_ID" 2>/dev/null | grep -q "cloudresourcemanager.googleapis.com"; then
        echo -e "${GREEN}Cloud Resource Manager API 활성화 완료!${NC}"
        break
    fi
    echo -e "활성화 전파 대기 중... (${i}/15)"
    sleep 2
done

# 2. 테라폼 설치 여부 검증 및 필요 시 자동 설치
echo -e "\n${YELLOW}[2단계] Terraform CLI 가용 여부를 체크하는 중...${NC}"

INSTALL_TERRAFORM=false

if ! command -v terraform &> /dev/null; then
    INSTALL_TERRAFORM=true
else
    # terraform version 출력을 가져와 stub 여부 판별 (안내 문구 포함 시 stub으로 간주)
    TF_VER_OUT=$(terraform version 2>&1 || echo "failed")
    if [[ "$TF_VER_OUT" == *"install terraform"* ]] || \
       [[ "$TF_VER_OUT" == *"Follow the instructions"* ]] || \
       [[ "$TF_VER_OUT" == "failed" ]]; then
        INSTALL_TERRAFORM=true
    fi
fi

if [ "$INSTALL_TERRAFORM" = true ]; then
    echo -e "${YELLOW}Terraform이 설치되어 있지 않거나 정상 작동하지 않습니다. 자동 설치를 시작합니다...${NC}"
    
    # OS 및 패키지 매니저 확인 (apt-get 지원 여부)
    if command -v apt-get &> /dev/null; then
        echo -e "Debian/Ubuntu 계열 환경(예: Cloud Shell)이 감지되었습니다. apt를 통해 설치를 진행합니다."
        
        # 의존성 패키지 설치
        sudo apt-get update -y && sudo apt-get install -y gnupg software-properties-common curl
        
        # HashiCorp GPG 키 및 저장소 등록
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        
        # 테라폼 설치
        sudo apt-get update -y && sudo apt-get install -y terraform
        
        # 설치 확인
        if ! terraform version &> /dev/null; then
            echo -e "${RED}[ERROR] Terraform 자동 설치에 실패했습니다. 수동으로 설치해 주세요.${NC}"
            exit 1
        fi
        echo -e "${GREEN}Terraform 설치가 완료되었습니다!${NC}"
        
        # Cloud Shell 세션 유지 설정 자동 등록 (선택 사항)
        if [ -d "$HOME" ] && { [ ! -f "$HOME/.customize_environment" ] || ! grep -q "terraform" "$HOME/.customize_environment" 2>/dev/null; }; then
            echo -e "${BLUE}Cloud Shell 세션 재연결 시 테라폼을 유지하기 위해 $HOME/.customize_environment 파일에 설정을 추가합니다.${NC}"
            cat << 'EOF' >> "$HOME/.customize_environment"
# Auto-installed by setup.sh
if ! terraform version &> /dev/null; then
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update && sudo apt-get install -y terraform
fi
EOF
        fi
    else
        echo -e "${RED}[ERROR] 자동 설치는 Debian/Ubuntu 계열 환경(GCP Cloud Shell 포함)만 지원합니다.${NC}"
        echo -e "현재 환경에서는 수동으로 테라폼을 설치한 후 다시 실행해 주세요."
        exit 1
    fi
fi

echo -e "Terraform 가용 여부: ${GREEN}OK${NC}"

# 3. terraform.tfvars 자동 생성 및 프로젝트 ID 설정 (변경 감지 시 초기화)
echo -e "\n${YELLOW}[3단계] 테라폼 환경 변수 파일(terraform.tfvars) 설정 중...${NC}"
TF_DIR="terraform/infra"

if [ ! -d "$TF_DIR" ]; then
    echo -e "${RED}[ERROR] 테라폼 인프라 디렉토리($TF_DIR)를 찾을 수 없습니다.${NC}"
    exit 1
fi

# 기존 설정된 프로젝트 ID 감지 (tfvars 및 tfstate 기반)
PREV_PROJECT_ID=""
if [ -f "$TF_DIR/terraform.tfvars" ]; then
    PREV_PROJECT_ID=$(sed -n 's/project_id\s*=\s*"\(.*\)"/\1/p' "$TF_DIR/terraform.tfvars" | tr -d ' ' 2>/dev/null || true)
fi

RESET_STATE=false

# 1) tfvars 내부 프로젝트 ID가 다른 경우
if [ -n "$PREV_PROJECT_ID" ] && [ "$PREV_PROJECT_ID" != "$PROJECT_ID" ]; then
    RESET_STATE=true
fi

# 2) tfvars가 유실되었어도 tfstate가 존재하는데 현재 프로젝트 ID 정보가 없는 경우
if [ -f "$TF_DIR/terraform.tfstate" ]; then
    if ! grep -q "$PROJECT_ID" "$TF_DIR/terraform.tfstate" 2>/dev/null; then
        RESET_STATE=true
    fi
fi

# 프로젝트 ID 변경 감지 시 상태 파일 및 캐시 강제 제거
if [ "$RESET_STATE" = true ]; then
    echo -e "${YELLOW}[경고] 이전 사용된 GCP 프로젝트 설정이 현재 프로젝트($PROJECT_ID)와 다릅니다.${NC}"
    echo -e "${YELLOW}인프라 정합성을 위해 기존 테라폼 상태 파일 및 캐시를 완전히 초기화합니다...${NC}"
    rm -rf "$TF_DIR/.terraform" "$TF_DIR/terraform.tfstate" "$TF_DIR/terraform.tfstate.backup" "$TF_DIR/.terraform.lock.hcl"
fi

# terraform.tfvars 생성
cat <<EOF > "$TF_DIR/terraform.tfvars"
project_id = "$PROJECT_ID"
region     = "asia-northeast3"
EOF

echo -e "${GREEN}terraform.tfvars 생성 및 설정 완료!${NC} (Project ID: $PROJECT_ID, Region: asia-northeast3)"

# 3.5. GCP 서비스 에이전트(Service Agent) 강제 생성 및 대기
echo -e "\n${YELLOW}[3.5단계] 주요 서비스 에이전트(Service Agent) 계정을 강제 활성화하는 중...${NC}"
echo -e "BigQuery Data Transfer 및 Dataplex 서비스 에이전트를 활성화합니다."
gcloud beta services identity create --service=bigquerydatatransfer.googleapis.com --project="$PROJECT_ID" 2>/dev/null || true
gcloud beta services identity create --service=dataplex.googleapis.com --project="$PROJECT_ID" 2>/dev/null || true
echo -e "서비스 에이전트 계정 전파를 위해 잠시 대기합니다 (10초)..."
sleep 10

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
