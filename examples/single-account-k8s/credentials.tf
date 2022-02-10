module "iam_user" {
  source                   = "../../modules/infrastructure/permissions/iam-user"
  name                     = var.name
  ssm_secure_api_token_arn = module.ssm.secure_api_token_secret_arn
  deploy_threat_detection  = var.deploy_threat_detection
  deploy_image_scanning    = local.deploy_image_scanning
}
