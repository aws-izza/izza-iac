#---------------IAM Module------
module "aws_load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.3.1" # Use a compatible version, check module releases for latest

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider = data.aws_eks_cluster.example.identity[0].oidc[0].issuer
      provider_arn = aws_iam_openid_connect_provider.example.arn
      namespace    = "kube-system"
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

data "aws_iam_policy_document" "ec2describe" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*", "elasticloadbalancing:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "ec2-policies"
  description = "not in the alb controller module"
  policy      = data.aws_iam_policy_document.ec2describe.json
}

resource "aws_iam_role_policy_attachment" "ec2attach" {
  role = module.aws_load_balancer_controller_irsa_role.iam_role_name
  policy_arn = aws_iam_policy.policy.arn
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.aws_load_balancer_controller_irsa_role.iam_role_arn
    }
  }
}

#---------------Helm_release------
resource "helm_release" "aws_load_balancer_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  namespace        = "kube-system"
  version          = "1.13.2" # Pin to a specific compatible version for K8s 1.29
  create_namespace = false    # Assumes kube-system namespace already exists

  # For CRD management: The helm_release resource handles CRDs on first install.
  # For upgrades, if CRDs change between chart versions, consider a separate
  # kubernetes_manifest resource to ensure CRDs are always up-to-date.
  # Example (requires downloading the CRD YAML for the specific chart version):
  # resource "kubernetes_manifest" "aws_lbc_crds" {
  #   yaml_body = file("${path.module}/crds/v1_13_2_crds.yaml") # Path to downloaded CRD file
  # }
  # depends_on = [kubernetes_manifest.aws_lbc_crds]

  set {
    name  = "clusterName"
    value = aws_eks_cluster.example.name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [ kubernetes_service_account.aws_load_balancer_controller ]

  # Optional: Set region and vpcId if IMDS is restricted or for Fargate/Hybrid nodes
  # set {
  #   name  = "region"
  #   value = var.aws_region
  # }
  # set {
  #   name  = "vpcId"
  #   value = data.aws_eks_cluster.this.vpc_id
  # }

  # HA configuration (default in chart v1.2.0+ is 2 replicas)
  # set {
  #   name  = "replicaCount"
  #   value = "2"
  # }
  # set {
  #   name  = "podDisruptionBudget.maxUnavailable"
  #   value = "1"
  # }

  # Optional: Enable cert-manager integration if required for TLS certificate management
  # set {
  #   name  = "enableCertManager"
  #   value = "false" # Set to true if cert-manager is installed and desired
  # }

  # Optional: Node isolation for critical components (security best practice)
  # set {
  #   name  = "nodeSelector.kubernetes\\.io/os"
  #   value = "linux"
  # }
  # set {
  #   name  = "tolerations.key"
  #   value = "CriticalAddonsOnly"
  # }
  # set {
  #   name  = "tolerations.operator"
  #   value = "Exists"
  # }
}

#---------------Output------
output "aws_load_balancer_controller_service_account_arn" {
  description = "The ARN of the IAM Service Account for the AWS Load Balancer Controller."
  value       = module.aws_load_balancer_controller_irsa_role.iam_role_arn
}

output "aws_load_balancer_controller_helm_release_name" {
  description = "The name of the Helm release for the AWS Load Balancer Controller."
  value       = helm_release.aws_load_balancer_controller.name
}