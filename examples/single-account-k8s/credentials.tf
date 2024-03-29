module "iam_user" {
  source = "../../modules/infrastructure/permissions/iam-user"
  count  = var.deploy_aws_iam_user ? 1 : 0
  name   = var.name

  deploy_image_scanning = var.deploy_image_scanning_ecr || var.deploy_image_scanning_ecs

  ssm_secure_api_token_arn       = module.ssm.secure_api_token_secret_arn
  cloudtrail_s3_bucket_arn       = length(module.cloudtrail) > 0 ? module.cloudtrail[0].s3_bucket_arn : "*"
  cloudtrail_subscribed_sqs_arn  = module.cloud_connector_sqs.cloudtrail_sns_subscribed_sqs_arn
  scanning_codebuild_project_arn = length(module.codebuild) > 0 ? module.codebuild[0].project_arn : "*"
}
