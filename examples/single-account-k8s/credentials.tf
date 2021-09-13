module "credentials" {
  source = "../../modules/infrastructure/permissions/single-account-user"
  name   = var.name

  secure_api_token_secret_name       = module.ssm.secure_api_token_secret_name
  cloudtrail_s3_bucket_arn           = module.cloudtrail.s3_bucket_arn
  cloudtrail_sns_subscribed_sqs_arns = [module.cloud_connector_sqs.cloudtrail_sns_subscribed_sqs_arn, module.cloud_scanning_sqs.cloudtrail_sns_subscribed_sqs_arn]
  scanning_build_project_arn         = module.codebuild.project_arn

  tags = var.tags
  # required to avoid ParameterNotFound on tf-plan
  depends_on = [module.ssm]
}
