# File auto-generated by command: ./bin/make-example vars eks ecr-credentials-sync v2.1.5

## Ignored by config.json:module_mapping_vars
#variable "ecr_credentials_sync_cluster_oidc_issuer_url" {
#  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
#  type        = string
#}

variable "ecr_credentials_sync_tags" {
  description = "Tags to apply to all resources."
  type        = any
  default     = {}
}
