#### Flux #####
###############

variable "flux_aws_region" {
  description = "AWS Region."
  type        = string
}

variable "flux_cluster_name" {
  description = "EKS cluster name."
  type        = string
}

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
  default     = ""
}

variable "flux_version" {
  description = "Flux version."
  type        = string
  default     = "v2.2.3"
}
