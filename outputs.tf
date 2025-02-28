output "postgres_password" {
    value     = random_password.postgres_password.result
    sensitive = true
}