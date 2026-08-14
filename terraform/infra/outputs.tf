output "network_id" {
  description = "The ID of the VPC network"
  value       = module.vpc.network_id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = module.vpc.network_name
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = module.vpc.public_subnet_id
}

output "public_subnet_name" {
  description = "The name of the public subnet"
  value       = module.vpc.public_subnet_name
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = module.vpc.private_subnet_id
}

output "private_subnet_name" {
  description = "The name of the private subnet"
  value       = module.vpc.private_subnet_name
}

output "private_subnet_usce1_id" {
  description = "The ID of the private subnet in us-central1"
  value       = module.vpc.private_subnet_id
}

output "private_subnet_usce1_name" {
  description = "The name of the private subnet in us-central1"
  value       = module.vpc.private_subnet_name
}

output "ui_repository_url" {
  description = "The Artifact Registry repository URL to push the built Docker image to"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.ui_repo.repository_id}/${var.ui_service_name}"
}

output "ui_service_url" {
  description = "The public web URL of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.ui_service.uri
}

