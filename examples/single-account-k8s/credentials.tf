module "iam_user" {
  source                   = "../../modules/infrastructure/permissions/iam-user"
  name                     = var.name
  ssm_secure_api_token_arn = module.ssm.secure_api_token_secret_arn
  enable_cloud_connector   = var.enable_cloud_connector
  enable_cloud_scanning    = var.enable_cloud_scanning
}
