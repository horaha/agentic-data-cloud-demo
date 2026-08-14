# Introduce a 30-second delay after enabling APIs to allow GCP propagation
resource "time_sleep" "wait_api_propagation" {
  depends_on = [module.apis]
  create_duration = "30s"
}

# Artifact Registry Repository to store the UI Docker image
resource "google_artifact_registry_repository" "ui_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.ui_repository_name
  description   = "Docker repository for the Dataplex Business User Interface"
  format        = "DOCKER"

  depends_on = [time_sleep.wait_api_propagation]
}

# Cloud Run v2 service for the Single Container Web Application
resource "google_cloud_run_v2_service" "ui_service" {
  name                = var.ui_service_name
  location            = var.region
  project             = var.project_id
  deletion_protection = false

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      ports {
        container_port = 8080
      }

      # Inject placeholders replacement env variables to the entrypoint script
      env {
        name  = "VITE_API_URL"
        value = "/api"
      }
      env {
        name  = "VITE_API_VERSION"
        value = "v1"
      }
      env {
        name  = "VITE_ADMIN_EMAIL"
        value = var.admin_email
      }
      env {
        name  = "VITE_GOOGLE_PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "VITE_GOOGLE_CLIENT_ID"
        value = var.oauth_client_id
      }
      env {
        name  = "VITE_GOOGLE_REDIRECT_URI"
        value = "/auth/google/callback"
      }
      env {
        name  = "GOOGLE_CLOUD_PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "GCP_LOCATION"
        value = "global"
      }
      env {
        name  = "GCP_REGION"
        value = "global"
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  # Ensure registry repository is created before service attempts to fetch image from it
  depends_on = [google_artifact_registry_repository.ui_repo]
}

# Allow invoker access to the Cloud Run service for the admin user
resource "google_cloud_run_v2_service_iam_member" "allow_unauthenticated" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.ui_service.name
  role     = "roles/run.invoker"
  member   = "user:${var.admin_email}"
}
