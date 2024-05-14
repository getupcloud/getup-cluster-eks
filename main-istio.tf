# File auto-generated from ./bin/vars2tf

module "istio" {
  source = "github.com/getupcloud/terraform-modules//modules/istio?ref=v0.15.9"

  istio_version            = var.istio_version
  istio_namespace          = var.istio_namespace
  istio_base_values        = var.istio_base_values
  istio_base_set           = var.istio_base_set
  istio_base_set_list      = var.istio_base_set_list
  istiod_values            = var.istiod_values
  istiod_set               = var.istiod_set
  istiod_set_list          = var.istiod_set_list
  ingress_gateway_values   = var.ingress_gateway_values
  ingress_gateway_set      = var.ingress_gateway_set
  ingress_gateway_set_list = var.ingress_gateway_set_list
  egress_gateway_values    = var.egress_gateway_values
  egress_gateway_set       = var.egress_gateway_set
  egress_gateway_set_list  = var.egress_gateway_set_list
}
