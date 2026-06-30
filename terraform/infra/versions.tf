terraform {
  required_version = ">= 1.5.0"

  # backend "gcs" {
  #   bucket = "tfstate-agentic-data-cloud-demo-asne3"
  #   prefix = "infra"
  # }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}
