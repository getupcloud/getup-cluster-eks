output "customer_name" {
  description = "Name of the customer."
  value       = var.customer_name
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_provider" {
  description = "Cloud Provider or platform where cluster is running."
  value       = var.cluster_provider
}

output "cluster_sla" {
  description = "SLA fot the cluster."
  value       = var.cluster_sla
}

output "aws_load_balancer_controller_iam_role_arn" {
  description = "AWS Load Balancer Controller Role ARN."
  value       = module.eks.aws_load_balancer_controller_iam_role_arn
}

output "loki_iam_role_arn" {
  description = "Loki Role ARN."
  value       = module.loki.loki_iam_role_arn
}

output "loki_s3_bucket_name" {
  description = "Loki S3 Bucket name."
  value       = module.loki.loki_s3_bucket_name
}

output "cert_manager_iam_role_arn" {
  description = "Cert-Manager Role ARN."
  value       = module.cert-manager.cert_manager_iam_role_arn
}

output "ecr_credentials_sync_iam_role_arn" {
  description = "ECR Credentials Sync Role ARN."
  value       = module.ecr-credentials-sync.ecr_credentials_sync_iam_role_arn
}

output "aws_eso_iam_role_arn" {
  description = "AWS External Secrets Operator role ARN."
  value       = module.aws-external-secrets-operator.aws_eso_iam_role_arn
}

