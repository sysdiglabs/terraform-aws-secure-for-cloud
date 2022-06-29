locals {
  deploy_image_scanning = var.deploy_image_scanning_ecs || var.deploy_image_scanning_ecr
}
