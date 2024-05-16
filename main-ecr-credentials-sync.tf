# File auto-generated from ./bin/vars2tf

module "ecr-credentials-sync" {
  source = "github.com/getupcloud/terraform-modules//modules/ecr-credentials-sync?ref=v0.15.17"

  ecr_credentials_sync_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  ecr_credentials_sync_tags                    = var.ecr_credentials_sync_tags
}
