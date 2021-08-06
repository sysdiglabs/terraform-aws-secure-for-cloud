
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
      queueURL: ${aws_sqs_queue.sqs.id}
%{if var.organizational_setup.is_organizational}
      assumeRole: ${var.organizational_setup.services_assume_role_arn}
%{endif~}
      interval: 25s
notifiers:
  - cloudwatch:
      logGroup: ${aws_cloudwatch_log_group.log.name}
      logStream: ${aws_cloudwatch_log_stream.stream.name}
CONFIG
}
