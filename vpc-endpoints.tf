# VPC 엔드포인트용 보안 그룹들
resource "aws_security_group" "izza_endpoints_sg" {
  name_prefix = "izza-endpoints-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for VPC endpoints with restricted access"

  ingress {
    description = "All TCP From VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "izza-endpoints-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# VPC 엔드포인트 모듈
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = module.vpc.vpc_id

  # 보안 그룹 생성 완료 후 실행되도록 의존성 추가
  depends_on = [
    aws_security_group.izza_endpoints_sg
  ]

  endpoints = {

    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids # Private RT에만 연결
      tags = {
        Name        = "izza-vpce-s3"
        Environment = var.environment
        Project     = var.project_name
      }
    }

    # ECR API 인터페이스 엔드포인트
    ecr_api = {
      service             = "ecr.api"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.izza_endpoints_sg.id]
      private_dns_enabled = true
      tags = {
        Name        = "izza-ecr-api-eni"
        Environment = var.environment
        Project     = var.project_name
      }
    }

    # ECR DKR 인터페이스 엔드포인트
    ecr_dkr = {
      service             = "ecr.dkr"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.izza_endpoints_sg.id]
      private_dns_enabled = true
      tags = {
        Name        = "izza-ecr-dkr-eni"
        Environment = var.environment
        Project     = var.project_name
      }
    }

    # CloudWatch Logs 인터페이스 엔드포인트
    logs = {
      service             = "logs"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.izza_endpoints_sg.id]
      private_dns_enabled = true
      tags = {
        Name        = "izza-cloud-watch-logs-eni"
        Environment = var.environment
        Project     = var.project_name
      }
    }

    # AWS Secrets Manager 인터페이스 엔드포인트
    secretsmanager = {
      service             = "secretsmanager"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.izza_endpoints_sg.id]
      private_dns_enabled = true
      tags = {
        Name        = "izza-secretmanager"
        Environment = var.environment
        Project     = var.project_name
      }
    }

    # EC2 인터페이스 엔드포인트 (EKS에서 필요)
    ec2 = {
      service             = "ec2"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.izza_endpoints_sg.id]
      private_dns_enabled = true
      tags = {
        Name        = "izza-ec2-eni"
        Environment = var.environment
        Project     = var.project_name
      }
    }

    # EKS 인터페이스 엔드포인트
    eks = {
      service             = "eks"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.izza_endpoints_sg.id]
      private_dns_enabled = true
      tags = {
        Name        = "izza-eks-eni"
        Environment = var.environment
        Project     = var.project_name
      }
    }

    # STS 인터페이스 엔드포인트 (IRSA에 필요)
    sts = {
      service             = "sts"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.izza_endpoints_sg.id]
      private_dns_enabled = true
      tags = {
        Name        = "izza-sts-eni"
        Environment = var.environment
        Project     = var.project_name
      }
    }

    # Auto Scaling 인터페이스 엔드포인트 (EKS 노드 그룹용)
    autoscaling = {
      service             = "autoscaling"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.izza_endpoints_sg.id]
      private_dns_enabled = true
      tags = {
        Name        = "izza-autoscaling-eni"
        Environment = var.environment
        Project     = var.project_name
      }
    }

    # SSM 인터페이스 엔드포인트 (Systems Manager)
    ssm = {
      service             = "ssm"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.izza_endpoints_sg.id]
      private_dns_enabled = true
      tags = {
        Name        = "izza-ssm-eni"
        Environment = var.environment
        Project     = var.project_name
      }
    }

    # SSM Messages 인터페이스 엔드포인트 (Session Manager용)
    ssmmessages = {
      service             = "ssmmessages"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.izza_endpoints_sg.id]
      private_dns_enabled = true
      tags = {
        Name        = "izza-ssmmessages-eni"
        Environment = var.environment
        Project     = var.project_name
      }
    }

    # EC2 Messages 인터페이스 엔드포인트 (EC2 인스턴스 통신용)
    ec2messages = {
      service             = "ec2messages"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.izza_endpoints_sg.id]
      private_dns_enabled = true
      tags = {
        Name        = "izza-ec2messages-eni"
        Environment = var.environment
        Project     = var.project_name
      }
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
