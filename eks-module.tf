module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "eks-izza"
  cluster_version = "1.33"

  # EKS 지원 정책 설정 (STANDARD 또는 EXTENDED)
  cluster_upgrade_policy = {
    support_type = "STANDARD"
  }

  enable_cluster_creator_admin_permissions = true

  # VPC 모듈에서 생성된 VPC 사용
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # 클러스터 엔드포인트 설정 (보안 강화)
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = var.workspace_ip_cidrs

  # 클러스터 애드온 (기본 애드온만)
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # 노드 그룹 공통 IAM 정책 (SSM 접근 권한 포함)
  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  # EKS 관리형 노드 그룹
  eks_managed_node_groups = {
    # 시스템 워크로드용 (ArgoCD, 시스템 컴포넌트)
    "system" = {
      name = "eks-izza-system"

      instance_types = ["t3.medium"]
      ami_type       = "AL2023_x86_64_STANDARD"

      min_size     = 1
      max_size     = 3
      desired_size = 1

      subnet_ids    = module.vpc.private_subnets
      capacity_type = "ON_DEMAND"

      # 시스템 워크로드 전용 테인트
    #   taints = [
    #     {
    #       key    = "node-type"
    #       value  = "system"
    #       effect = "NO_SCHEDULE"
    #     }
    #   ]

      labels = {
        "node-type" = "system"
        "workload"  = "system"
      }

      update_config = {
        max_unavailable = 1
      }

      tags = {
        Environment = var.environment
        Project     = var.project_name
        NodeType    = "system"
      }
    }

    # Jenkins 마스터용 노드 그룹 (안정성 중시)
    "jenkins-master" = {
      name = "eks-izza-jenkins"

      instance_types = ["t3.medium"] # Jenkins 마스터는 스케줄링만 담당
      ami_type       = "AL2023_x86_64_STANDARD"

      min_size     = 1
      max_size     = 2
      desired_size = 1

      subnet_ids    = module.vpc.private_subnets
      capacity_type = "ON_DEMAND" # Jenkins 마스터는 안정성을 위해 ON_DEMAND

      # Jenkins 마스터 전용 테인트
    #   taints = [
    #     {
    #       key    = "node-type"
    #       value  = "jenkins-master"
    #       effect = "NO_SCHEDULE"
    #     }
    #   ]

      labels = {
        "node-type" = "jenkins-master"
        "workload"  = "ci-cd-master"
      }

      update_config = {
        max_unavailable = 1
      }

      tags = {
        Environment = var.environment
        Project     = var.project_name
        NodeType    = "jenkins-master"
      }
    }

    # # Jenkins 빌드 에이전트용 SPOT 노드 그룹 (Go, Java, Python 빌드)
    # "jenkins-build-agents" = {
    #   name = "eks-izza-agents"

    #   instance_types = ["c5.large", "c5.xlarge", "m5.large"] # CPU 집약적 빌드를 위해 C/M 시리즈
    #   ami_type       = "AL2_x86_64"

    #   min_size     = 0 # 필요할 때만 스케일 업
    #   max_size     = 5 # Go, Java, Python 병렬 빌드 지원
    #   desired_size = 0

    #   subnet_ids    = module.vpc.private_subnets
    #   capacity_type = "SPOT" # 빌드 에이전트는 SPOT 사용

    #   # 빌드 에이전트 전용 테인트
    #   taints = [
    #     {
    #       key    = "node-type"
    #       value  = "build-agent"
    #       effect = "NO_SCHEDULE"
    #     }
    #   ]

    #   labels = {
    #     "node-type" = "build-agent"
    #     "workload"  = "ci-build"
    #     "build-env" = "multi-lang"
    #   }

    #   update_config = {
    #     max_unavailable_percentage = 50
    #   }

    #   tags = {
    #     Environment = var.environment
    #     Project     = var.project_name
    #     NodeType    = "build-agent"
    #   }
    # }



    # 애플리케이션 워크로드용
#     "application" = {
#       name = "eks-izza-app"

#       instance_types = ["m5.large", "m5.xlarge"] # 안정적인 성능을 위해 M 시리즈 사용
#       ami_type       = "AL2023_x86_64_STANDARD"

#       min_size     = 1
#       max_size     = 6
#       desired_size = 1

#       subnet_ids    = module.vpc.private_subnets
#       capacity_type = "ON_DEMAND"

#       labels = {
#         "node-type" = "application"
#         "workload"  = "app"
#       }

#       update_config = {
#         max_unavailable = 1
#       }

#       tags = {
#         Environment = var.environment
#         Project     = var.project_name
#         NodeType    = "application"
#       }
#     }
  }

  # 클러스터 보안 그룹 추가 규칙
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # 노드 보안 그룹 추가 규칙
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    # ALB에서 노드로의 트래픽 허용
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  # 태그
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# AWS Load Balancer Controller용 IRSA 역할
module "aws_load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.3.1"

  role_name = "eks-izza-aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
