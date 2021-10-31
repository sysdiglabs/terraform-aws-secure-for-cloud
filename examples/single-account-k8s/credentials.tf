module "credentials_general" {
  source = "../../modules/infrastructure/permissions/general"
  name   = var.name

  secure_api_token_secret_arn = module.ssm.secure_api_token_secret_arn

  tags = var.tags
}


module "credentials_cloud_connector" {
  source = "../../modules/infrastructure/permissions/cloud-connector"
  name   = var.name

  sfc_user_name                 = module.credentials_general.sfc_user_name
  cloudtrail_s3_bucket_arn      = module.cloudtrail.s3_bucket_arn
  cloudtrail_subscribed_sqs_arn = module.cloud_connector_sqs.cloudtrail_sns_subscribed_sqs_arn

  depends_on = [module.credentials_general]
}


module "credentials_cloud_scanning" {
  source = "../../modules/infrastructure/permissions/cloud-scanning"
  name   = var.name

  sfc_user_name                  = module.credentials_general.sfc_user_name
  scanning_codebuild_project_arn = module.codebuild.project_arn
  cloudtrail_subscribed_sqs_arn  = module.cloud_scanning_sqs.cloudtrail_sns_subscribed_sqs_arn

  depends_on = [module.credentials_general]
}
