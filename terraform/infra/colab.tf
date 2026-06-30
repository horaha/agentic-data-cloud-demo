# 6. Colab Enterprise 런타임 템플릿 생성
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
