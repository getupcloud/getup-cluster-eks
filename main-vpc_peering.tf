# File auto-generated from ./bin/vars2tf

module "vpc_peering" {
  source = "github.com/getupcloud/terraform-modules//modules/vpc_peering?ref=v0.16.3"

  vpc_peering_owner_vpc_id          = var.vpc_peering_owner_vpc_id
  vpc_peering_owner_route_table_ids = var.vpc_peering_owner_route_table_ids
  vpc_peering_peer_vpc_id           = var.vpc_peering_peer_vpc_id
  vpc_peering_peer_route_table_ids  = var.vpc_peering_peer_route_table_ids
  vpc_peering_tags                  = var.vpc_peering_tags
}
