# File auto-generated by command: ./bin/make-example vars eks vpc_peering v2.1.5

variable "vpc_peering_owner_vpc_id" {
  type = string
}

variable "vpc_peering_owner_route_table_ids" {
  type    = list(string)
  default = []

  validation {
    condition     = length(var.vpc_peering_owner_route_table_ids) > 0
    error_message = "Invalid length: ${length(var.vpc_peering_owner_route_table_ids)}."
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
    error_message = "Invalid length: ${length(var.vpc_peering_peer_route_table_ids)}."
  }
}

variable "vpc_peering_tags" {
  description = "(Optional) Tags to apply to all resources."
  type        = any
  default     = {}
}
