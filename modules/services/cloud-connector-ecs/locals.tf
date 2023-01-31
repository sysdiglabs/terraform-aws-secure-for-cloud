locals {
  deploy_image_scanning                = var.deploy_image_scanning_ecs || var.deploy_image_scanning_ecr || var.deploy_beta_image_scanning_ecr
  deploy_image_scanning_with_codebuild = (var.deploy_image_scanning_ecs || var.deploy_image_scanning_ecr) && !var.deploy_beta_image_scanning_ecr

  verify_ssl = var.verify_ssl == "auto" ? length(regexall("https://.*?\\.sysdig(cloud)?.com/?", data.sysdig_secure_connection.current.secure_url)) == 1 : var.verify_ssl == "true"

  # this must satisfy input provided existing cluster ARNs and just created cluster format
  # ex. input var: 'foo'
  # ex. just created cluster name, gathered through tf data : 'arn:aws:ecs:eu-west-3:425287181461:cluster/foo'
  sanitized_cluster_name = coalesce(split("/", join("/", [var.ecs_cluster_name, ""]))[1], var.ecs_cluster_name)
}

