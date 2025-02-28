resource "google_sql_database_instance" "db_instance" {
    name             = "db-instance"
    region           = var.region
    database_version = "POSTGRES_14"

    settings {
        tier             = "db-f1-micro"
        availability_type = "REGIONAL"
        ip_configuration {
        ipv4_enabled = false
        psc_config {
            psc_enabled               = true
            allowed_consumer_projects = var.allowed_consumer_projects
        }
        }
    }

    deletion_protection = false
}