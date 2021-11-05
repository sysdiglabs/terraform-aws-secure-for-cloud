output "k8s_region" {
  value = var.region
}

output "k8s_name" {
  value = aws_eks_cluster.aws_eks.name
}
output "k8s_endpoint" {
  value = aws_eks_cluster.aws_eks.endpoint
}

output "k8s_kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.aws_eks.certificate_authority[0].data
}

output "k8s_auth_token" {
  sensitive = true
  value     = data.aws_eks_cluster_auth.eks_auth.token
}
