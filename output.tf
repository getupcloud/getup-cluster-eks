output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
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
  value       = module.cert_manager_irsa.iam_role_arn
}
