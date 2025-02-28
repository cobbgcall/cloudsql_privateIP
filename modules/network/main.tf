resource "google_compute_network" "peering_network" {
    name                    = "peering-network"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "peering_subnet_1" {
    name                     = "peering-subnet-1"
    ip_cidr_range            = var.peering_subnet_cidr_1
    network                  = google_compute_network.peering_network.id
    private_ip_google_access = true
    region                   = var.region
}

resource "google_compute_subnetwork" "peering_subnet_2" {
    name                     = "peering-subnet-2"
    ip_cidr_range            = var.peering_subnet_cidr_2
    network                  = google_compute_network.peering_network.id
    private_ip_google_access = true
    region                   = var.region
}

resource "google_compute_subnetwork" "peering_subnet_3" {
    name                     = "peering-subnet-3"
    ip_cidr_range            = var.peering_subnet_cidr_3
    network                  = google_compute_network.peering_network.id
    private_ip_google_access = true
    region                   = var.region
}

resource "google_compute_router" "peering_router" {
    name    = "peering-router"
    network = google_compute_network.peering_network.id
    region  = var.region
}

resource "google_compute_router_nat" "peering_nat" {
    project                         = var.project
    name                            = "peering-nat"
    router                          = google_compute_router.peering_router.name
    region                          = var.region
    nat_ip_allocate_option          = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "peering_fw" {
    project     = var.project
    name        = "peering-fw"
    network     = google_compute_network.peering_network.id
    direction   = "INGRESS"
    priority    = "1000"
    allow {
        protocol = "TCP"
        ports    = ["22"]
    }
    source_ranges = var.source_ranges
    target_tags   = ["peering-fw"]
}

resource "google_compute_address" "private_ip_address" {
    name        = "private-ip-address"
    subnetwork  = google_compute_subnetwork.peering_subnet_1.id
    address_type = "INTERNAL"
    address     = var.private_ip_address
    region      = var.region

    depends_on = [google_sql_database_instance.db_instance]
}

resource "google_compute_forwarding_rule" "psc_forwarding_rule" {
    name                  = "psc-forwarding-rule"
    region                = var.region
    load_balancing_scheme = ""
    network               = google_compute_network.peering_network.id
    ip_address            = google_compute_address.private_ip_address.id
    target                = google_sql_database_instance.db_instance.psc_service_attachment_link

    depends_on = [google_compute_address.private_ip_address]
}