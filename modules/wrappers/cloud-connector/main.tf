
# --------------------------------------------------
# wrapper to workaround count+provision usage
# FIX-PROPOSAL. handle all input params as object inputs?
# --------------------------------------------------

module "cloud_connector" {
  count = var.enable ? 1 : 0

  source = "../../services/cloud-connector"
  name   = var.name

  sysdig_secure_endpoint       = var.sysdig_secure_endpoint
  secure_api_token_secret_name = var.secure_api_token_secret_name

  is_organizational     = var.is_organizational
  organizational_config = var.organizational_config

  sns_topic_arn = var.sns_topic_arn

  ecs_cluster = var.ecs_cluster
  vpc_id      = var.vpc_id
  vpc_subnets = var.vpc_subnets

  tags = var.tags
}
