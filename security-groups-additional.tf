# 추가 보안 강화를 위한 보안 그룹들

# EKS 전용 VPC 엔드포인트 보안 그룹 (가장 제한적)
resource "aws_security_group" "eks_vpc_endpoints_sg" {
  name_prefix = "eks-vpc-endpoints-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Highly restricted security group for EKS VPC endpoints"

  # EKS 클러스터 보안 그룹에서만 접근 허용
  ingress {
    description     = "HTTPS from EKS cluster only"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  # EKS 노드 보안 그룹에서만 접근 허용
  ingress {
    description     = "HTTPS from EKS nodes only"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  # 아웃바운드는 HTTPS만
  egress {
    description = "HTTPS outbound only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "eks-vpc-endpoints-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 관리용 보안 그룹 (운영자 접근용)
resource "aws_security_group" "admin_access_sg" {
  name_prefix = "admin-access-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for administrative access"

  # 특정 관리 IP에서만 접근 허용 (예시)
  # ingress {
  #   description = "Admin access from office"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["203.0.113.0/24"]  # 실제 사무실 IP로 변경
  # }

  # 현재는 Private 서브넷에서만 접근 허용
  ingress {
    description = "Admin HTTPS from Private Subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    description = "All outbound for admin tasks"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "admin-access-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}
