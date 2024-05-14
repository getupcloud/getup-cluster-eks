# File auto-generated from ./bin/vars2tf

module "opencost" {
  source = "github.com/getupcloud/terraform-modules//modules/opencost?ref=v0.15.1"

  opencost_cluster_oidc_issuer_url      = module.eks.cluster_oidc_issuer_url
  opencost_namespace                    = var.opencost_namespace
  opencost_service_account              = var.opencost_service_account
  opencost_tags                         = var.opencost_tags
  opencost_cluster_name                 = module.eks.cluster_name
  opencost_create_spot_datafeed_bucket  = var.opencost_create_spot_datafeed_bucket
  opencost_spot_datafeed_bucket_name    = var.opencost_spot_datafeed_bucket_name
  opencost_spot_datafeed_prefix         = var.opencost_spot_datafeed_prefix
  opencost_spot_datafeed_retention_days = var.opencost_spot_datafeed_retention_days
}
