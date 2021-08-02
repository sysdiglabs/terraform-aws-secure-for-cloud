output "id" {
  value       = aws_ecs_cluster.ecs_cluster.id
  description = "ECS Cluster ID"
}


output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "vpc id"
}

output "vpc_subnets" {
  value       = module.vpc.private_subnets
  description = "vpc privates subnets"
}
