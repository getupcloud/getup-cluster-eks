# File auto-generated from ./bin/filter-vars

#### Flux #####
###############

#variable "flux_aws_region" {
#  description = "AWS Region."
#  type        = string
#}

#variable "flux_cluster_name" {
#  description = "EKS cluster name."
#  type        = string
#}

variable "flux_github_token" {
  description = "GitHub OAuth / Personal Access Token. Can also by provided via the GITHUB_TOKEN environment variable."
  type        = string
  default     = ""
  sensitive   = true
}

variable "flux_github_org" {
  description = "GitHub organization or individual user account to manage."
  type        = string
  default     = ""
}

variable "flux_github_repository" {
  description = "Name of the GitHub repository."
  type        = string
  default     = ""
}

variable "flux_path" {
  description = "Path relative to the repository root, when specified the cluster sync will be scoped to this path."
  type        = string
  default     = "cluster"
}

variable "flux_version" {
  description = "Flux version."
  type        = string
  default     = "v2.2.3"
}

variable "flux_overlay" {
  description = "Map of variables to inject into overlay files."
  type        = map(string)
  default = {
    aws_eso_iam_role_arn : ""
    cronitor_ping_url : ""
    ecr_credential_sync_region : ""
    msteams_channel_url : ""
    opencost_spot_datafeed_bucket_name : ""
    opencost_spot_datafeed_bucket_prefix : ""
    opsgenie_integration_api_key : ""
    pagerduty_service_key : ""
    slack_api_url : ""
    slack_channel : ""
    teleport_auth_token : ""
  }
}
