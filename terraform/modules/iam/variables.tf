variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "account_id" {
  description = "The account ID for the service account"
  type        = string
}

variable "display_name" {
  description = "The display name for the service account"
  type        = string
}

variable "roles" {
  description = "The roles to assign to the service account"
  type        = list(string)
}
