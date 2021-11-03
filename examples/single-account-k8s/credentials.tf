module "iam_user" {
  source                   = "../../modules/infrastructure/permissions/iam-user"
  name                     = var.name
  ssm_secure_api_token_arn = module.ssm.secure_api_token_secret_arn
}
