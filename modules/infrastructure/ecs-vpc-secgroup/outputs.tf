output "ecs_cluster_name" {
  value       = aws_ecs_cluster.ecs_cluster.id
  description = "ID of the ECS cluster"
}

output "ecs_vpc_id" {
  value       = local.ecs_vpc_id
  description = "ID of the VPC for the ECS cluster"
}
output "ecs_vpc_subnets_private" {
  value       = length(module.vpc) > 0 ? module.vpc[0].private_subnets : var.ecs_vpc_subnets_private
  description = "ID of the private subnets of the VPC for the ECS cluster"
}

output "ecs_sg_id" {
  value       = aws_security_group.sg.id
  description = "ID of the Security Group for the ECS cluster VPC"
}
