locals {
  verify_ssl            = var.verify_ssl == "auto" ? length(regexall("https://.*?\\.sysdig(cloud)?.com/?", data.sysdig_secure_connection.current.secure_url)) == 1 : var.verify_ssl == "true"
  deploy_image_scanning = var.deploy_image_scanning_ecs || var.deploy_image_scanning_ecr
}
