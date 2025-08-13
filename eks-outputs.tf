# EKS 관련 출력값 (EKS 모듈 활성화 후 사용)
# VPC import 완료 후 활성화하세요

# output "cluster_endpoint" {
#   description = "Endpoint for EKS control plane"
#   value       = module.eks.cluster_endpoint
# }

# output "cluster_name" {
#   description = "EKS cluster name"
#   value       = module.eks.cluster_name
# }

# output "cluster_arn" {
#   description = "The Amazon Resource Name (ARN) of the cluster"
#   value       = module.eks.cluster_arn
# }

# output "cluster_certificate_authority_data" {
#   description = "Base64 encoded certificate data required to communicate with the cluster"
#   value       = module.eks.cluster_certificate_authority_data
# }

# output "cluster_oidc_issuer_url" {
#   description = "The URL on the EKS cluster for the OpenID Connect identity provider"
#   value       = module.eks.cluster_oidc_issuer_url
# }

# output "cluster_security_group_id" {
#   description = "Security group ID attached to the EKS cluster"
#   value       = module.eks.cluster_security_group_id
# }

# output "node_security_group_id" {
#   description = "Security group ID attached to the EKS node group"
#   value       = module.eks.node_security_group_id
# }

# output "eks_managed_node_groups" {
#   description = "Map of attribute maps for all EKS managed node groups created"
#   value       = module.eks.eks_managed_node_groups
# }

# output "aws_load_balancer_controller_role_arn" {
#   description = "The ARN of the IAM role for AWS Load Balancer Controller"
#   value       = module.aws_load_balancer_controller_irsa_role.iam_role_arn
# }

# output "cluster_addons" {
#   description = "Map of attribute maps for all EKS cluster addons enabled"
#   value       = module.eks.cluster_addons
# }

# output "aws_load_balancer_controller_addon_status" {
#   description = "Status of the AWS Load Balancer Controller addon"
#   value       = try(module.eks.cluster_addons["aws-load-balancer-controller"]["status"], "not_installed")
# }