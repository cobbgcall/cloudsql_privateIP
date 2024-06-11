provider "google" {
    project                         = "mimetic-retina-410109"
    region                          = "us-central1"     
}

locals {
    service_list = [ 
        "compute.googleapis.com"
    ]
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
            psc_config {
              psc_enabled           = true
              allowed_consumer_projects = [ "mimetic-retina-410109" ] 
            }       
        }   
    }

    deletion_protection             = false 
}

resource "google_sql_user" "db_user" {
    project                         = "mimetic-retina-410109"
    name                            = "db-user"
    instance                        = google_sql_database_instance.db_instance.name
    password                        = random_password.postgres_password.result 
}

resource "random_password" "postgres_password" {
    length                          = 8 
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

resource "google_compute_router" "peering_router" {
    name                            = "peering-router"
    network                         = google_compute_network.peering_network.id
    region                          = "us-central1"  
}

resource "google_compute_router_nat" "peering_nat" {
    project                         = "mimetic-retina-410109" 
    name                            = "peering-nat"
    router                          = google_compute_router.peering_router.name
    region                          = "us-central1"
    nat_ip_allocate_option          = "AUTO_ONLY" 
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "peering_fw" {
    project                         = "mimetic-retina-410109"
    name                            = "peering-fw"
    network                         = google_compute_network.peering_network.id
    direction                       = "INGRESS"
    priority                        = "1000"
    allow {
        protocol = "TCP"
        ports = ["22"] 
        }
    source_ranges                   = ["0.0.0.0/0"]
    target_tags                     = ["peering-fw"]
}

resource "google_compute_address" "private_ip_address" {
    name                            = "private-ip-address"
    subnetwork                      = google_compute_subnetwork.peering_subnet.id 
    address_type                    = "INTERNAL"
    address                         = "10.10.0.24"
    region                          = "us-central1"

    depends_on = [ google_sql_database_instance.db_instance ]

}

resource "google_compute_forwarding_rule" "psc_forwarding_rule" {
    name                            = "psc-forwarding-rule"
    region                          = "us-central1"
    load_balancing_scheme           = "" 
    network                         = google_compute_network.peering_network.id
    ip_address                      = google_compute_address.private_ip_address.id
    target                          = google_sql_database_instance.db_instance.psc_service_attachment_link

    depends_on = [ google_compute_address.private_ip_address ]
}

output "postgres_password" {
    value                           = random_password.postgres_password.result
    sensitive                       = true
}