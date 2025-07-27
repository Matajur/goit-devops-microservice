# Common outputs
output "db_name" {
  description = "The database name"
  value       = var.db_name
}

output "db_username" {
  description = "The database username"
  value       = var.username
  sensitive   = true
}

output "db_password" {
  description = "The database password"
  value       = var.password
  sensitive   = true
}

# output "db_endpoint" {
#   description = "The endpoint address of the database (RDS or Aurora)"
#   value = var.use_aurora ? aws_rds_cluster.aurora.endpoint : aws_db_instance.standard.endpoint
# }

output "db_endpoint" {
  value = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].endpoint
}

output "db_port" {
  value = var.db_port
}
