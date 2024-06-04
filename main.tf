provider "google" {
    project                         = "mimetic-retina-410109"
    region                          = "us-central1"     
}

resource "google_compute_subnetwork" "peering_subnet" {
    name                            = "peering-subnet"
    ip_cidr_range                   = "10.10.0.0/24"
    network                         = google_compute_network.peering_network.id
    private_ip_google_access        = true
    region                          = "us-central1" 
}

resource "google_compute_network" "peering_network" {
    name                            = "peering-network"
    auto_create_subnetworks         = false 
}

resource "google_compute_address" "private_ip_address" {
    name                            = "private-ip-address"
    region                          = "us-cenrtal1"
    address_type                    = "INTERNAL"
    subnetwork                      = google_compute_subnetwork.peering_subnet.self_link[0]
    address                         = "10.10.0.24"

    depends_on = [ google_sql_database_instance.db_instance ]
}

resource "google_sql_database_instance" "db_instance" {
    name                            = "db-instance"
    region                          = "us-central1"
    database_version                = "POSTGRES_14"

    settings {
        tier                        = "db-f1-micro"
        availability_type           = "REGIONAL"
        ip_configuration {
          ipv4_enabled              = false
          //private_network           = google_compute_network.peering_network.id
          psc_config {
            psc_enabled             = true
            allowed_consumer_projects = []
          }     
        }   
    }

    deletion_protection             = false 
}

resource "google_compute_forwarding_rule" "vms_cloudsql" {
    name                            = "psc-forwarding-rule-cloudsql"
    region                          = "us-central1"
    network                         = "peering-network"
    ip_address                      = google_compute_address.private_ip_address.self_link
    load_balancing_scheme           = ""
    target                          = google_sql_database_instance.db_instance.psc_service_attachment_link

    depends_on = [ google_compute_address.private_ip_address ]
}