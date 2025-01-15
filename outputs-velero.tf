# File auto-generated from ./bin/outputs

output "velero_iam_role_arn" {
  description = "Velero Role ARN."
  value       = module.velero.velero_iam_role_arn
}

output "velero_s3_bucket_name" {
  description = "Velero S3 Bucket name."
  value       = module.velero.velero_s3_bucket_name
}
