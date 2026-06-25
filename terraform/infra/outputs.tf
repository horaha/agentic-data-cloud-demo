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
  value       = google_compute_subnetwork.private_subnet_usce1.id
}

output "private_subnet_usce1_name" {
  description = "The name of the private subnet in us-central1"
  value       = google_compute_subnetwork.private_subnet_usce1.name
}
