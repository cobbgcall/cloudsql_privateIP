output "network_id" {
    value = google_compute_network.peering_network.id
}

output "subnet_1_id" {
    value = google_compute_subnetwork.peering_subnet_1.id
}

output "subnet_2_id" {
    value = google_compute_subnetwork.peering_subnet_2.id
}

output "subnet_3_id" {
    value = google_compute_subnetwork.peering_subnet_3.id
}

output "private_ip_address" {
    value = google_compute_address.private_ip_address.address
}