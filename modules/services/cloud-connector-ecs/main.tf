data "aws_region" "current" {}

locals {
  verify_ssl   = var.verify_ssl == "auto" ? length(regexall("https://.*?\\.sysdig(cloud)?.com/?", data.sysdig_secure_connection.current.secure_url)) == 1 : var.verify_ssl == "true"
  cluster_name = coalesce(split("/", var.ecs_cluster_name)[1],var.ecs_cluster_name)
}
