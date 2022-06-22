locals {
  deploy_image_scanning   = var.deploy_image_scanning_ecs || var.deploy_image_scanning_ecr
  deploy_scanning_infra   = local.deploy_image_scanning && !var.use_scanning_v2
  ecr_standalone_scanning = var.deploy_image_scanning_ecr && var.use_scanning_v2
  ecs_standalone_scanning = var.deploy_image_scanning_ecs && var.use_scanning_v2
  ecr_scanning_with_infra = var.deploy_image_scanning_ecr && !var.use_scanning_v2
  ecs_scanning_with_infra = var.deploy_image_scanning_ecs && !var.use_scanning_v2
}
