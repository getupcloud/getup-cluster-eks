# File auto-generated from ./bin/outputs

output "eks_aws_account_id" {
  description = "AWS Account ID"
  value       = module.eks.eks_aws_account_id
}

output "eks_aws_region" {
  description = "AWS Region."
  value       = module.eks.eks_aws_region
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.eks_cluster_arn
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.eks_cluster_certificate_authority_data
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.eks.eks_cluster_id
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.eks_cluster_oidc_issuer_url
}

output "eks_cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.eks.eks_cluster_platform_version
}

output "eks_cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = module.eks.eks_cluster_status
}

output "eks_cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.eks.eks_cluster_primary_security_group_id
}

output "eks_cluster_vpc_id" {
  description = "ID of the cluster VPC"
  value       = module.eks.eks_cluster_vpc_id
}

output "eks_cluster_vpc_private_route_table_ids" {
  description = "Route table IDs from the cluster private subnets."
  value       = module.eks.eks_cluster_vpc_private_route_table_ids
}

output "eks_default_storage_class_name" {
  description = "Default StorageClass name"
  value       = module.eks.eks_default_storage_class_name
}

output "eks_cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = module.eks.eks_cluster_security_group_arn
}

output "eks_cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = module.eks.eks_cluster_security_group_id
}

output "eks_node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the node shared security group"
  value       = module.eks.eks_node_security_group_arn
}

output "eks_node_security_group_id" {
  description = "ID of the node shared security group"
  value       = module.eks.eks_node_security_group_id
}

output "eks_oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.eks.eks_oidc_provider
}

output "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.eks.eks_oidc_provider_arn
}

output "eks_cluster_tls_certificate_sha1_fingerprint" {
  description = "The SHA1 fingerprint of the public key of the cluster's certificate"
  value       = module.eks.eks_cluster_tls_certificate_sha1_fingerprint
}

output "eks_cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = module.eks.eks_cluster_iam_role_name
}

output "eks_cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks.eks_cluster_iam_role_arn
}

output "eks_cluster_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.eks.eks_cluster_iam_role_unique_id
}

output "eks_cluster_addons" {
  description = "Map of attribute maps for all EKS cluster addons enabled"
  value       = module.eks.eks_cluster_addons
}

output "eks_aws_load_balancer_controller_iam_role_arn" {
  description = "AWS Load Balancer Controller Role ARN."
  value       = module.eks.eks_aws_load_balancer_controller_iam_role_arn
}

output "eks_cluster_identity_providers" {
  description = "Map of attribute maps for all EKS identity providers enabled"
  value       = module.eks.eks_cluster_identity_providers
}

output "eks_cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = module.eks.eks_cloudwatch_log_group_name
}

output "eks_cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = module.eks.eks_cloudwatch_log_group_arn
}

output "eks_fargate_profiles" {
  description = "Map of attribute maps for all EKS Fargate Profiles created"
  value       = module.eks.eks_fargate_profiles
}

output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks.eks_managed_node_groups
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
}

output "eks_self_managed_node_groups" {
  description = "Map of attribute maps for all self managed node groups created"
  value       = module.eks.eks_self_managed_node_groups
}

output "eks_self_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by self-managed node groups"
  value       = module.eks.eks_self_managed_node_groups_autoscaling_group_names
}

output "eks_karpenter_iam_role_name" {
  description = "The name of the IAM role for service accounts"
  value       = module.eks.eks_karpenter_iam_role_name
}

output "eks_karpenter_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role for service accounts"
  value       = module.eks.eks_karpenter_iam_role_arn
}

output "eks_karpenter_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role for service accounts"
  value       = module.eks.eks_karpenter_iam_role_unique_id
}

output "eks_karpenter_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.eks.eks_karpenter_queue_arn
}

output "eks_karpenter_queue_name" {
  description = "The name of the created Amazon SQS queue"
  value       = module.eks.eks_karpenter_queue_name
}

output "eks_karpenter_queue_url" {
  description = "The URL for the created Amazon SQS queue"
  value       = module.eks.eks_karpenter_queue_url
}

output "eks_karpenter_event_rules" {
  description = "Map of the event rules created and their attributes"
  value       = module.eks.eks_karpenter_event_rules
}

output "eks_karpenter_node_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.eks.eks_karpenter_node_iam_role_name
}

output "eks_karpenter_node_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.eks.eks_karpenter_node_iam_role_arn
}

output "eks_karpenter_node_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.eks.eks_karpenter_node_iam_role_unique_id
}

output "eks_karpenter_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = module.eks.eks_karpenter_instance_profile_arn
}

output "eks_karpenter_instance_profile_id" {
  description = "Instance profile's ID"
  value       = module.eks.eks_karpenter_instance_profile_id
}

output "eks_karpenter_instance_profile_name" {
  description = "Name of the instance profile"
  value       = module.eks.eks_karpenter_instance_profile_name
}

output "eks_karpenter_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = module.eks.eks_karpenter_instance_profile_unique
}
