terraform {
  backend "s3" {
    bucket         = "izza-terraform-state-dev-20250813"
    key            = "terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "izza-terraform-state-lock-dev"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.83"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.region
}

# EKS 클러스터 생성 후 활성화할 데이터 소스들
# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_name
# }