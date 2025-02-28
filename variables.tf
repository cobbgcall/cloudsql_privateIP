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