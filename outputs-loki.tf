# File auto-generated from ./bin/outputs

output "loki_iam_role_arn" {
  description = "Loki Role ARN."
  value       = module.loki.loki_iam_role_arn
}

output "loki_s3_bucket_name" {
  description = "Loki S3 Bucket name."
  value       = module.loki.loki_s3_bucket_name
}
