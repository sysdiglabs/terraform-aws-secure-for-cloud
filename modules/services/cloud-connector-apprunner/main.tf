locals {
  verify_ssl              = var.verify_ssl == "auto" ? length(regexall("https://.*?\\.sysdig(cloud)?.com/?", data.sysdig_secure_connection.current.secure_url)) == 1 : var.verify_ssl == "true"
  deploy_image_scanning   = var.deploy_image_scanning_ecs || var.deploy_image_scanning_ecr
  deploy_scanning_infra   = local.deploy_image_scanning && !var.use_standalone_scanner
  ecr_standalone_scanning = var.deploy_image_scanning_ecr && var.use_standalone_scanner
  ecs_standalone_scanning = var.deploy_image_scanning_ecs && var.use_standalone_scanner
  ecr_scanning_with_infra = var.deploy_image_scanning_ecr && !var.use_standalone_scanner
  ecs_scanning_with_infra = var.deploy_image_scanning_ecs && !var.use_standalone_scanner
}
