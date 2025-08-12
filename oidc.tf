data "aws_eks_cluster" "example" {
  name = aws_eks_cluster.example.name
  # Ensure the cluster resource is created before this data source is read
  depends_on = [aws_eks_cluster.example]
}

data "aws_eks_cluster_auth" "example_auth" {
  name = aws_eks_cluster.example.name
  # Ensure the cluster resource is created before this data source is read
  depends_on = [aws_eks_cluster.example]
}

resource "aws_iam_openid_connect_provider" "example" {
  url             = data.aws_eks_cluster.example.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd10df6"]
}

output "oidc_url" {
  value = data.aws_eks_cluster.example.identity[0].oidc[0].issuer
}