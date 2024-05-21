# File auto-generated from ./bin/outputs

output "rds_hostname" {
  description = "The address of the RDS instance"
  value       = module.rds.rds_hostname
}

output "rds_port" {
  description = "The database port"
  value       = module.rds.rds_port
}

output "rds_database_name" {
  description = "The database name"
  value       = module.rds.rds_database_name
}

output "rds_username" {
  description = "The master username for the database"
  value       = module.rds.rds_username
  sensitive   = true
}

output "rds_user_secret_arn" {
  description = "The ARN of the master user secret"
  value       = module.rds.rds_user_secret_arn
}

output "rds_endpoint" {
  description = "The connection endpoint"
  value       = module.rds.rds_endpoint
}
