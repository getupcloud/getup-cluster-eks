# File auto-generated from ./bin/vars2tf

module "argocd" {
  source = "github.com/getupcloud/terraform-modules//modules/argocd?ref=v0.15.9"

  argocd_repository = var.argocd_repository
  argocd_version    = var.argocd_version
  argocd_namespace  = var.argocd_namespace
  argocd_values     = var.argocd_values
  argocd_set        = var.argocd_set
  argocd_set_list   = var.argocd_set_list
}
