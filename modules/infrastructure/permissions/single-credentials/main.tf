module "credentials_general" {
  source                      = "../general"
  name                        = var.name
  secure_api_token_secret_arn = var.ssm_secure_api_token_arn
  tags                        = var.tags
}


module "credentials_cloud_connector" {
  count  = var.enable_cloud_connector ? 1 : 0
  source = "../cloud-connector"
  name   = var.name

  sfc_user_name                 = module.credentials_general.sfc_user_name
  cloudtrail_s3_bucket_arn      = var.cloudtrail_s3_bucket_arn
  cloudtrail_subscribed_sqs_arn = var.cloudtrail_subscribed_sqs_arn

  depends_on = [module.credentials_general]
}

module "credentials_cloud_scanning" {
  count  = var.enable_cloud_scanning ? 1 : 0
  source = "../cloud-scanning"
  name   = var.name

  sfc_user_name                  = module.credentials_general.sfc_user_name
  scanning_codebuild_project_arn = var.scanning_codebuild_project_arn
  cloudtrail_subscribed_sqs_arn  = var.cloudtrail_subscribed_sqs_arn

  depends_on = [module.credentials_general]
}
