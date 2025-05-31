variable "customer_name" {
  description = "Name of the customer."
  type        = string
}

variable "cluster_provider" {
  description = "Cloud Provider or platform where cluster is running. One of: eks, aks, doks, gke, oke, on-prem, okd, okd3, rancher, none."
  type        = string

  validation {
    condition     = contains(["eks", "aks", "doks", "gke", "oke", "on-prem", "okd", "okd3", "rancher", "none"], var.cluster_provider)
    error_message = "The Cluster Provider is invalid."
  }
}

variable "cluster_sla" {
  description = "SLA fot the cluster. One of: high, low, none."
  type        = string

  validation {
    condition     = contains(["high", "low", "none"], var.cluster_sla)
    error_message = "The Cluster SLA is invalid."
  }
}

variable "overlay" {
  description = "Map of variables to inject into overlay files."
  type        = map(string)
  default = {
    default_storage_class_name : ""
    default_ingress_class_name : ""
    default_ingresss_domain : ""
    certmanager_acme_email : ""
    cronitor_ping_url : ""
    ecr_credential_sync_region : ""
    msteams_channel_url : ""
    opsgenie_integration_api_key : ""
    pagerduty_service_key : ""
    slack_api_url : ""
    slack_channel : ""
    teleport_auth_token : ""
    datadog_api_key : ""
    aws_efs_filesystem_id : ""
  }
}

