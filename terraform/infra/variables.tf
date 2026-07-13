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

