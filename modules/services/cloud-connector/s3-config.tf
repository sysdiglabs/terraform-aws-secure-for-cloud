
locals {
  s3_bucket_config_id = aws_s3_bucket.s3_config_bucket.id
}

resource "aws_s3_bucket_object" "config" {
  bucket  = local.s3_bucket_config_id
  key     = "cloud-connector.yaml"
  content = local.default_config
  tags    = var.tags
}

locals {
  default_config = <<CONFIG
logging: info
rules:
  - s3:
      bucket: ${local.s3_bucket_config_id}
      path: rules
ingestors:
  - cloudtrail-sns-sqs:
      queueURL: ${module.cloud_connector_sqs.cloudtrail_sns_subscribed_sqs_url}
%{if var.is_organizational}
      assumeRole: ${var.organizational_config.sysdig_secure_for_cloud_role_arn}
%{endif~}
      interval: 25s
notifiers:
  - cloudwatch:
      logGroup: ${aws_cloudwatch_log_group.log.name}
      logStream: ${aws_cloudwatch_log_stream.stream.name}
CONFIG
}
