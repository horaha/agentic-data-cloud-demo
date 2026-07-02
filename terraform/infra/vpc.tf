# 2. VPC 생성
module "vpc" {
  source = "../modules/vpc"

  project_id            = var.project_id
  network_name          = "adc-demo-vpc"
  public_subnet_name    = "adc-demo-public-subnet-usce1"
  public_ip_cidr_range  = "10.0.0.0/24"
  private_subnet_name   = "adc-demo-private-subnet-usce1"
  private_ip_cidr_range = "10.0.100.0/24"
  region                = var.region

  depends_on = [module.apis]
}

resource "google_compute_subnetwork" "private_subnet_usce1" {
  name                     = "adc-demo-private-subnet-usce1"
  ip_cidr_range            = "10.0.101.0/24"
  region                   = "us-central1"
  network                  = module.vpc.network_id
  project                  = var.project_id
  private_ip_google_access = true

  depends_on = [module.apis]
}
