variable "project" {
    description = "The GCP project ID"
    type        = string
}

variable "region" {
    description = "The GCP region"
    type        = string
}

variable "allowed_consumer_projects" {
    description = "List of allowed consumer projects"
    type        = list(string)
}

variable "peering_subnet_cidr_1" {
    description = "The CIDR range for the first peering subnet"
    type        = string
}

variable "peering_subnet_cidr_2" {
    description = "The CIDR range for the second peering subnet"
    type        = string
}

variable "peering_subnet_cidr_3" {
    description = "The CIDR range for the third peering subnet"
    type        = string
}

variable "private_ip_address" {
    description = "The private IP address for the forwarding rule"
    type        = string
}

variable "source_ranges" {
    description = "The source ranges for the firewall rule"
    type        = list(string)
}