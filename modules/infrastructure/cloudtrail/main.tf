# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail
resource "aws_cloudtrail" "cloudtrail" {

  name = var.name

  is_organization_trail = var.is_organizational

  s3_bucket_name        = aws_s3_bucket.cloudtrail.id
  is_multi_region_trail = var.is_multi_region_trail

  kms_key_id     = var.cloudtrail_kms_enable ? aws_kms_key.cloudtrail_kms[0].arn : null
  sns_topic_name = aws_sns_topic.cloudtrail.id

  enable_logging                = true
  enable_log_file_validation    = true
  include_global_service_events = true

  tags = var.tags

  ## note: seems required to avoid racing conditions (InsufficientSnsTopicPolicyException on cloudtrail creation) /shrug
  depends_on = [
    aws_s3_bucket_policy.cloudtrail_s3,
    aws_sns_topic_policy.allow_cloudtrail_publish
  ]
}