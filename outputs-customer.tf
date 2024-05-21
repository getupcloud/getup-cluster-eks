output "customer_name" {
  description = "Name of the customer."
  value       = var.customer_name
}

output "cluster_provider" {
  description = "Cloud Provider or platform where cluster is running."
  value       = var.cluster_provider
}

output "cluster_sla" {
  description = "SLA fot the cluster."
  value       = var.cluster_sla
}
