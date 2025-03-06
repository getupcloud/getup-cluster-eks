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
