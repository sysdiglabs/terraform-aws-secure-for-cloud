output "id" {
  value       = aws_ecs_cluster.ecs_cluster.id
  description = "ECS Cluster ID"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "VPC Public Subnets"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "VPC Private Subnets"
}
