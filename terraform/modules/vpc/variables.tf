variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region for the subnets"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "public_subnet_name" {
  description = "The name of the public subnet"
  type        = string
}

variable "public_ip_cidr_range" {
  description = "The IP CIDR range for the public subnet"
  type        = string
}

variable "private_subnet_name" {
  description = "The name of the private subnet"
  type        = string
}

variable "private_ip_cidr_range" {
  description = "The IP CIDR range for the private subnet"
  type        = string
}
