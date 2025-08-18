# VPC 모듈을 사용한 네트워크 구성
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  # 기본 VPC 설정
  name = "${var.project_name}-${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  # 가용 영역 설정 (2개 AZ 사용)
  azs = ["${var.region}a", "${var.region}b"]

  # 서브넷 CIDR 설정 (기존 구성과 일치)
  private_subnets = ["10.0.128.0/20", "10.0.144.0/20"]
  public_subnets  = ["10.0.0.0/20", "10.0.16.0/20"]

  # NAT Gateway 설정 (단일 NAT Gateway 사용)
  enable_nat_gateway     = true # NAT Gateway 생성 활성화
  enable_vpn_gateway     = false
  single_nat_gateway     = true # 모든 private subnet이 하나의 NAT Gateway 공유
  one_nat_gateway_per_az = false

  # DNS 설정
  enable_dns_hostnames = true
  enable_dns_support   = true

  # 기본 리소스 관리 설정
  manage_default_route_table    = false # 기본 Route Table 관리 안함
  manage_default_network_acl    = true  # Network ACL 관리
  manage_default_security_group = true  # 기본 보안 그룹 관리 (보안상 중요)

  # EKS를 위한 서브넷 태그
  public_subnet_tags = {
    Name                             = "izza-public-subnet"
    "kubernetes.io/role/elb"         = "1"
    "kubernetes.io/cluster/eks-izza" = "owned"
  }

  private_subnet_tags = {
    Name                              = "izza-private-subnet"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/eks-izza"  = "owned"
  }

  # 공통 태그
  tags = {
    Name        = "izza-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }

  # VPC 태그
  vpc_tags = {
    Name = "izza-vpc"
  }

  # Internet Gateway 태그
  igw_tags = {
    Name = "izza-igw"
  }

  # NAT Gateway 태그
  nat_gateway_tags = {
    Name = "izza-nat"
  }

  # Route Table 태그
  public_route_table_tags = {
    Name = "izza-rtb-public"
  }

  private_route_table_tags = {
    Name = "izza-rtb-private"
  }
}

# VPC 엔드포인트는 별도 파일(vpc-endpoints.tf)에서 관리
