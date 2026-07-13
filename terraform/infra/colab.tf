# 6. Colab Enterprise 환경 구성

resource "random_id" "colab_suffix" {
  byte_length = 4
}

# Colab Enterprise 런타임 템플릿 생성
resource "google_colab_runtime_template" "colab_template_usce1" {
  name         = "adc-demo-template-${var.colab_machine_type}-${random_id.colab_suffix.hex}"
  display_name = "Colab Runtime Template (us-central1)"
  location     = var.region
  description  = "Colab Enterprise Runtime Template in us-central1"

  machine_spec {
    machine_type = var.colab_machine_type
  }

  network_spec {
    enable_internet_access = true
    network                = module.vpc.network_id
    subnetwork             = module.vpc.private_subnet_id
  }

  shielded_vm_config {
    enable_secure_boot = true
  }

  depends_on = [module.vpc, time_sleep.wait_for_service_agents]
}

# 템플릿 기반으로 실습용 런타임(VM) 사전 생성
resource "google_colab_runtime" "colab_runtime" {
  name         = "adc-demo-runtime-${var.colab_machine_type}-${random_id.colab_suffix.hex}"
  display_name = "ADC Demo Runtime"
  location     = var.region
  
  # 실행 사용자 이메일을 지정하여 권한 바인딩 해결
  runtime_user = var.runtime_user

  notebook_runtime_template_ref {
    notebook_runtime_template = google_colab_runtime_template.colab_template_usce1.id
  }


  depends_on = [google_colab_runtime_template.colab_template_usce1]
}

