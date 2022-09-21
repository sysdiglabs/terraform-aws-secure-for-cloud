locals {
  deploy_image_scanning                = var.deploy_image_scanning_ecs || var.deploy_image_scanning_ecr || var.deploy_beta_image_scanning_ecr
  deploy_image_scanning_with_codebuild = var.deploy_image_scanning_ecs || var.deploy_image_scanning_ecr
}
