variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "node_group_instance_type" {
  description = "Application node group instance type"
  type        = string
  default     = "m5.large" # 안정적인 성능을 위해 M 시리즈 사용
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "izza"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "eks_support_type" {
  description = "EKS cluster support type - STANDARD or EXTENDED"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EXTENDED"], var.eks_support_type)
    error_message = "EKS support type must be either STANDARD or EXTENDED."
  }
}

variable "eks_admin_users" {
  description = "List of IAM users to grant EKS admin access"
  type        = list(string)
  default     = []
}

variable "eks_admin_roles" {
  description = "List of IAM roles to grant EKS admin access"
  type        = list(string)
  default     = []
}

variable "workspace_ip_cidrs" {
  description = "List of CIDR blocks that can access the EKS cluster endpoint publicly"
  type        = list(string)
  default     = [
    "118.218.200.33/32",
    "116.38.198.62/32",
    "118.218.200.112/32",
    "175.211.89.92/32",
    "125.186.154.83/32",
    "211.234.195.253/32"
    ] # 보안을 위해 실제 사용 시 특정 IP로 제한 권장
}
