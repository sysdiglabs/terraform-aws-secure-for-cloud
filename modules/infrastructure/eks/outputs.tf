output "k8s_name" {
  value       = aws_eks_cluster.aws_eks.name
  description = "eks cluster name"
}
output "k8s_endpoint" {
  value       = aws_eks_cluster.aws_eks.endpoint
  description = "eks cluster endpoint"
}

output "k8s_kubeconfig_certificate_authority_data" {
  value       = aws_eks_cluster.aws_eks.certificate_authority[0].data
  description = "eks cluster certificate authority data"
}

output "k8s_auth_token" {
  sensitive   = true
  value       = data.aws_eks_cluster_auth.eks_auth.token
  description = "eks cluster auth token"
}
