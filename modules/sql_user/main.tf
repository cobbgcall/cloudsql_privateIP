resource "google_sql_user" "db_user" {
    project  = var.project
    name     = "db-user"
    instance = var.instance
    password = var.password
}