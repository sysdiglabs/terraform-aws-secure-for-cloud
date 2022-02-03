locals {
  ecs_deploy                  = var.ecs_cluster_name == "create"
  ecs_cluster_name            = local.ecs_deploy ? module.ecs_vpc_secgroup[0].ecs_cluster_name : var.ecs_cluster_name
  ecs_vpc_id                  = local.ecs_deploy ? module.ecs_vpc_secgroup[0].ecs_vpc_id : var.ecs_vpc_id
  ecs_vpc_subnets_private_ids = local.ecs_deploy ? module.ecs_vpc_secgroup[0].ecs_vpc_subnets_private_ids : var.ecs_vpc_subnets_private_ids
}

module "ecs_vpc_secgroup" {
  providers = {
    aws = aws.member
  }

  count  = local.ecs_deploy ? 1 : 0
  source = "../../modules/infrastructure/ecs-vpc-secgroup"

  name               = var.name
  ecs_vpc_region_azs = var.ecs_vpc_region_azs
  tags               = var.tags
}
