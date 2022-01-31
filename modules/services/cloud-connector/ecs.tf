locals {
  ecs_deploy     = var.ecs_cluster_id == "create"
  ecs_cluster_id = var.ecs_cluster_id == "create" ? aws_ecs_cluster.ecs_cluster[0].id : var.ecs_cluster_id

  ecs_vpc_deploy = var.ecs_cluster_id == "create"
  ecs_vpc_id     = var.ecs_cluster_id == "create" ? module.vpc[0].vpc_id : var.ecs_vpc_id

  ecs_vpc_subnets_private = var.ecs_cluster_id == "create" ? module.vpc[0].vpc_subnets_private : var.ecs_vpc_subnets_private

  ecs_sg_deploy = var.ecs_sg_id == "create"
  ecs_sg_id     = var.ecs_sg_id == "create" ? aws_security_group.sg[0].id : var.ecs_sg_id
}

resource "aws_ecs_cluster" "ecs_cluster" {
  count = local.ecs_deploy ? 1 : 0

  name = var.name
  tags = var.tags
}
