# File auto-generated from ./bin/vars2tf

module "cert-manager" {
  source = "github.com/getupcloud/terraform-modules//modules/cert-manager?ref=v0.14.0"

  cert_manager_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  cert_manager_tags                    = var.cert_manager_tags
}
