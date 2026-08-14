variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The default region"
  type        = string
  default     = "us-central1"
}

variable "runtime_user" {
  description = "The email of the user owning the Colab Enterprise runtime"
  type        = string
  default     = ""
}

variable "colab_machine_type" {
  description = "The machine type for Colab Enterprise runtime"
  type        = string
  default     = "n2-standard-2"
}

variable "oauth_client_id" {
  description = "The Google OAuth Client ID for the web app authentication"
  type        = string
  default     = ""
}

variable "admin_email" {
  description = "The administrator email address to set in app configs"
  type        = string
  default     = ""
}

variable "ui_service_name" {
  description = "The name of the Cloud Run service"
  type        = string
  default     = "dataplex-business-ui"
}

variable "ui_repository_name" {
  description = "The Artifact Registry repository name to hold the container"
  type        = string
  default     = "dataplex-ui-repo"
}

variable "ui_image_tag" {
  description = "The docker image tag to deploy"
  type        = string
  default     = "latest"
}

