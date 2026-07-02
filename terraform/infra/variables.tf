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
