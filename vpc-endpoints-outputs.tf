# VPC 엔드포인트 관련 출력값
output "vpc_endpoints" {
  description = "Array containing the full resource object and attributes for all endpoints created"
  value       = module.vpc_endpoints.endpoints
}

output "vpc_endpoint_s3_id" {
  description = "The ID of VPC endpoint for S3"
  value       = try(module.vpc_endpoints.endpoints["s3"]["id"], null)
}

output "vpc_endpoint_ecr_api_id" {
  description = "The ID of VPC endpoint for ECR API"
  value       = try(module.vpc_endpoints.endpoints["ecr_api"]["id"], null)
}

output "vpc_endpoint_ecr_dkr_id" {
  description = "The ID of VPC endpoint for ECR DKR"
  value       = try(module.vpc_endpoints.endpoints["ecr_dkr"]["id"], null)
}

output "vpc_endpoint_logs_id" {
  description = "The ID of VPC endpoint for CloudWatch Logs"
  value       = try(module.vpc_endpoints.endpoints["logs"]["id"], null)
}

output "vpc_endpoint_secretsmanager_id" {
  description = "The ID of VPC endpoint for Secrets Manager"
  value       = try(module.vpc_endpoints.endpoints["secretsmanager"]["id"], null)
}

output "vpc_endpoint_ec2_id" {
  description = "The ID of VPC endpoint for EC2"
  value       = try(module.vpc_endpoints.endpoints["ec2"]["id"], null)
}

output "vpc_endpoint_eks_id" {
  description = "The ID of VPC endpoint for EKS"
  value       = try(module.vpc_endpoints.endpoints["eks"]["id"], null)
}

output "vpc_endpoint_sts_id" {
  description = "The ID of VPC endpoint for STS"
  value       = try(module.vpc_endpoints.endpoints["sts"]["id"], null)
}

output "izza_endpoints_sg_id" {
  description = "The ID of the izza-endpoints-sg security group"
  value       = aws_security_group.izza_endpoints_sg.id
}