variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The default region"
  type        = string
  default     = "asia-northeast3"
}

variable "runtime_user" {
  description = "The email of the user owning the Colab Enterprise runtime"
  type        = string
  default     = ""
}
