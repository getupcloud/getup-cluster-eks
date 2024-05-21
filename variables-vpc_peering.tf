# File auto-generated from ./bin/filter-vars

variable "vpc_peering_owner_vpc_id" {
  type = string
}

variable "vpc_peering_owner_route_table_ids" {
  type    = list(string)
  default = []

  validation {
    condition     = length(var.vpc_peering_owner_route_table_ids) > 0
    error_message = "INVALID LENGTH order: ${length(var.vpc_peering_owner_route_table_ids)}."
  }
}

variable "vpc_peering_peer_vpc_id" {
  type = string
}

variable "vpc_peering_peer_route_table_ids" {
  type    = list(string)
  default = []

  validation {
    condition     = length(var.vpc_peering_peer_route_table_ids) > 0
    error_message = "INVALID LENGTH peer: ${length(var.vpc_peering_peer_route_table_ids)}."
  }
}

variable "vpc_peering_tags" {
  description = "(Optional) Tags to apply to all resources."
  type        = any
  default     = {}
}
