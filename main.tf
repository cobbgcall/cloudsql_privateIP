provider "google" {
    project                         = "mimetic-retina-410109"
    region                          = "us-central1"     
}

resource "google_compute_network" "peering_network" {
    name                            = "peering-network"
    auto_create_subnetworks         = false 
}

resource "google_compute_subnetwork" "peering_subnet" {
    name                            = "peering-subnet"
    ip_cidr_range                   = "10.10.0.0/24"
    network                         = google_compute_network.peering_network.id
    private_ip_google_access        = true
    region                          = "us-central1" 
}

resource "google_compute_address" "private_ip_address" {
    name                            = "private-ip-address"
    purpose                         = "GCE_ENDPOINT"
    address_type                    = "INTERNAL"
    network                         = google_compute_network.peering_network.id 
    subnetwork                      = google_compute_subnetwork.peering_subnet.id 
}

resource "google_service_networking_connection" "snc_private_ip" {
    network                         = google_compute_network.peering_network.id
    service                         = "servicenetworking.googleapis.com"
    reserved_peering_ranges         = [google_compute_address.private_ip_address.name]
}

resource "google_sql_database_instance" "db_instance" {
    name                            = "db-instance"
    region                          = "us-central1"
    database_version                = "POSTGRES_14"

    settings {
        tier                        = "db-f1-micro"
        availability_type           = "REGIONAL"
        ip_configuration {
            ipv4_enabled            = false
            private_network         = google_compute_network.peering_network.id    
        }   
    }

    deletion_protection             = false 
}

resource "google_compute_forwarding_rule" "psc_forwarding_rule" {
    name                            = "psc-forwarding-rule"
    region                          = "us-central1"
    network                         = google_compute_network.peering_network.id
    ip_address                      = google_compute_address.private_ip_address.self_link
    target                          = google_sql_database_instance.db_instance.psc_service_attachment_link

    depends_on = [ google_compute_address.private_ip_address ]
}