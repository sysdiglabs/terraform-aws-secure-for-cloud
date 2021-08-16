# --------------------------------------------------
# wrapper to workaround count+provision usage
# FIX-PROPOSAL. handle all input params as object inputs?
# --------------------------------------------------

module "cloud_scanning" {
  count = var.enable ? 1 : 0

  source = "../../services/cloud-scanning"
  name   = var.name

  sysdig_secure_endpoint       = var.sysdig_secure_endpoint
  secure_api_token_secret_name = var.secure_api_token_secret_name

  build_project_arn  = var.build_project_arn
  build_project_name = var.build_project_name

  sns_topic_arn = var.sns_topic_arn

  ecs_cluster = var.ecs_cluster
  vpc_id      = var.vpc_id
  vpc_subnets = var.vpc_subnets

  tags = var.tags
}
