module "eks" {
  source = "git@github.com:getupcloud/terraform-modules//modules/eks?ref=v0.2.2"

  cluster_name                            = var.cluster_name
  kubernetes_version                      = var.kubernetes_version
  aws_region                              = var.aws_region
  tags                                    = var.tags
  cluster_encryption_config               = var.cluster_encryption_config
  vpc_id                                  = var.vpc_id
  private_subnet_ids                      = var.private_subnet_ids
  public_subnet_ids                       = var.public_subnet_ids
  control_plane_subnet_ids                = var.control_plane_subnet_ids
  azs                                     = var.azs
  vpc_name                                = var.vpc_name
  vpc_cidr                                = var.vpc_cidr
  create_cluster_security_group           = var.create_cluster_security_group
  cluster_security_group_id               = var.cluster_security_group_id
  cluster_security_group_name             = var.cluster_security_group_name
  cluster_endpoint_public_access_cidrs    = var.cluster_endpoint_public_access_cidrs
  cluster_endpoint_public_access          = var.cluster_endpoint_public_access
  vpc_cni_enable_prefix_delegation        = var.vpc_cni_enable_prefix_delegation
  fargate_profiles                        = var.fargate_profiles
  fallback_node_group_desired_size        = var.fallback_node_group_desired_size
  fallback_node_group_capacity_type       = var.fallback_node_group_capacity_type
  fallback_node_group_instance_types      = var.fallback_node_group_instance_types
  fallback_node_group_ami_type            = var.fallback_node_group_ami_type
  fallback_node_group_platform            = var.fallback_node_group_platform
  fallback_node_group_disk_size           = var.fallback_node_group_disk_size
  fallback_node_group_disk_type           = var.fallback_node_group_disk_type
  karpenter_namespace                     = var.karpenter_namespace
  karpenter_replicas                      = var.karpenter_replicas
  karpenter_node_class_ami_family         = var.karpenter_node_class_ami_family
  karpenter_node_pool_instance_arch       = var.karpenter_node_pool_instance_arch
  karpenter_node_pool_instance_category   = var.karpenter_node_pool_instance_category
  karpenter_node_group_spot_ratio         = var.karpenter_node_group_spot_ratio
  karpenter_node_pool_instance_cpu        = var.karpenter_node_pool_instance_cpu
  karpenter_node_pool_instance_memory_gb  = var.karpenter_node_pool_instance_memory_gb
  karpenter_cluster_limits_memory_gb      = var.karpenter_cluster_limits_memory_gb
  karpenter_cluster_limits_cpu            = var.karpenter_cluster_limits_cpu
  eks_iam_role_name                       = var.eks_iam_role_name
  iam_role_use_name_prefix                = var.iam_role_use_name_prefix
  iam_role_arn                            = var.iam_role_arn
  kms_key_administrators                  = var.kms_key_administrators
  aws_auth_user_arns                      = var.aws_auth_user_arns
  aws_auth_users                          = var.aws_auth_users
  aws_auth_user_groups                    = var.aws_auth_user_groups
  aws_auth_role_arns                      = var.aws_auth_role_arns
  aws_auth_roles                          = var.aws_auth_roles
  aws_auth_role_groups                    = var.aws_auth_role_groups
  aws_auth_accounts                       = var.aws_auth_accounts
  aws_auth_node_iam_role_arns_non_windows = var.aws_auth_node_iam_role_arns_non_windows
  keda_namespace                          = var.keda_namespace
  keda_replicas                           = var.keda_replicas
  keda_cron_schedule                      = var.keda_cron_schedule
  baloon_chart_version                    = var.baloon_chart_version
  baloon_namespace                        = var.baloon_namespace
  baloon_replicas                         = var.baloon_replicas
  baloon_cpu                              = var.baloon_cpu
  baloon_memory                           = var.baloon_memory
}

module "flux" {
  source = "git@github.com:getupcloud/terraform-modules//modules/flux?ref=v0.2.2"

  flux_aws_region                    = var.aws_region
  flux_cluster_name                  = module.eks.cluster_name
  flux_github_token                  = var.flux_github_token
  flux_github_org                    = var.flux_github_org
  flux_github_repository             = var.flux_github_repository
  flux_path                          = var.flux_path
}

module "istio" {
  source = "git@github.com:getupcloud/terraform-modules//modules/istio?ref=v0.2.2"

  istio_version   = var.istio_version
  istio_namespace = var.istio_namespace

  istio_base_values   = var.istio_base_values
  istio_base_set      = var.istio_base_set
  istio_base_set_list = var.istio_base_set_list

  istiod_values   = var.istiod_values
  istiod_set      = var.istiod_set
  istiod_set_list = var.istiod_set_list

  ingress_gateway_values   = var.ingress_gateway_values
  ingress_gateway_set      = var.ingress_gateway_set
  ingress_gateway_set_list = var.ingress_gateway_set_list

  egress_gateway_values   = var.egress_gateway_values
  egress_gateway_set      = var.egress_gateway_set
  egress_gateway_set_list = var.egress_gateway_set_list
}

