provider "google" {
    project = var.project
    region  = var.region
}

module "network" {
    source = "./modules/network"
    project = var.project
    region  = var.region
    peering_subnet_cidr_1 = var.peering_subnet_cidr_1
    peering_subnet_cidr_2 = var.peering_subnet_cidr_2
    peering_subnet_cidr_3 = var.peering_subnet_cidr_3
    private_ip_address  = var.private_ip_address
    source_ranges       = var.source_ranges
}

module "sql_instance" {
    source = "./modules/sql_instance"
    project = var.project
    region  = var.region
    allowed_consumer_projects = var.allowed_consumer_projects
}

module "sql_user" {
    source = "./modules/sql_user"
    project = var.project
    instance = module.sql_instance.instance_name
    password = random_password.postgres_password.result
}

resource "random_password" "postgres_password" {
    length = 16
}

output "postgres_password" {
    value     = random_password.postgres_password.result
    sensitive = true
}