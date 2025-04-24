# File auto-generated from ./bin/outputs

output "external_secrets_operator_iam_role_arn" {
  description = "AWS External Secrets Operator role ARN."
  value       = module.aws-external-secrets-operator.aws_eso_iam_role_arn
}
