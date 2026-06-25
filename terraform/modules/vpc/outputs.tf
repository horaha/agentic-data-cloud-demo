output "network_id" {
  value = google_compute_network.vpc.id
}

output "network_name" {
  value = google_compute_network.vpc.name
}

output "public_subnet_id" {
  value = google_compute_subnetwork.public_subnet.id
}

output "public_subnet_name" {
  value = google_compute_subnetwork.public_subnet.name
}

output "private_subnet_id" {
  value = google_compute_subnetwork.private_subnet.id
}

output "private_subnet_name" {
  value = google_compute_subnetwork.private_subnet.name
}
