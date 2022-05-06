data "aws_eks_cluster_auth" "eks_auth" {
  name = var.name
}
