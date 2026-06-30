# 6. Colab Enterprise 환경 구성

# 현재 테라폼을 구동하고 있는 사용자(실습자)의 구글 계정 이메일을 동적으로 조회
data "google_client_openid_userinfo" "me" {}

# Colab Enterprise 런타임 템플릿 생성
resource "google_colab_runtime_template" "colab_template_asne3" {
  name         = "adc-demo-template-asne3"
  display_name = "Colab Runtime Template (Seoul)"
  location     = var.region
  description  = "Colab Enterprise Runtime Template in asia-northeast3"

  machine_spec {
    machine_type = "e2-standard-4"
  }

  network_spec {
    enable_internet_access = true
    network                = module.vpc.network_id
    subnetwork             = module.vpc.private_subnet_id
  }

  depends_on = [module.vpc, time_sleep.wait_for_service_agents]
}

# 템플릿 기반으로 실습용 런타임(VM) 사전 생성
resource "google_colab_runtime" "colab_runtime" {
  name         = "adc-demo-runtime-asne3"
  display_name = "ADC Demo Runtime"
  location     = var.region
  
  # 실행 사용자 이메일을 지정하여 권한 바인딩 해결
  runtime_user = data.google_client_openid_userinfo.me.email

  notebook_runtime_template_ref {
    notebook_runtime_template = google_colab_runtime_template.colab_template_asne3.id
  }

  depends_on = [google_colab_runtime_template.colab_template_asne3]
}
