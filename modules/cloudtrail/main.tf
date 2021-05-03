locals {
  deploy_cloudtrail = var.existing_cloudtrail_sns_topic == ""
  is_multi_region   = var.multi_region_trail
  bucket_name       = "${substr(lower(var.naming_prefix), 0, 30)}-trail-"
}

data "aws_caller_identity" "me" {}

resource "aws_s3_bucket" "cloudtrail" {
  count = local.deploy_cloudtrail ? 1 : 0

  bucket_prefix = local.bucket_name
  force_destroy = true

  lifecycle_rule {
    enabled = true
    expiration {
      days = var.cloudtrail_log_retention
    }
  }
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  count = local.deploy_cloudtrail ? 1 : 0

  statement {
    sid       = "AWSCloudTrailAclCheck"
    actions   = ["s3:GetBucketAcl"]
    effect    = "Allow"
    resources = [aws_s3_bucket.cloudtrail[0].arn]
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
  }
  statement {
    sid       = "AWSCloudTrailWrite"
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.cloudtrail[0].arn}/AWSLogs/${data.aws_caller_identity.me.account_id}/*"]
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count = local.deploy_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id
  policy = data.aws_iam_policy_document.s3_bucket_policy[0].json
}

resource "aws_sns_topic" "sns" {
  count = local.deploy_cloudtrail ? 1 : 0

  name = "${var.naming_prefix}-CloudTrail"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  count = local.deploy_cloudtrail ? 1 : 0

  statement {
    sid    = "AWSCloudTrailSNSPolicy"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.sns[0].arn]
  }
}

resource "aws_sns_topic_policy" "sns" {
  count = local.deploy_cloudtrail ? 1 : 0

  arn    = aws_sns_topic.sns[0].arn
  policy = data.aws_iam_policy_document.sns_topic_policy[0].json
}

data "aws_iam_policy_document" "kms_key_policy" {
  policy_id = "Key policy created by CloudTrail"

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.me.account_id}:root"]
      type        = "AWS"
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.me.account_id}:trail/*"]
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
    }
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    actions   = ["kms:Decrypt", "kms:ReEncryptFrom"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.me.account_id]
      variable = "kms:CallerAccount"
    }
    condition {
      test     = "StringLike"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.me.account_id}:trail/*"]
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
    }
  }

  statement {
    sid    = "Allow alias creation during setup"
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    actions   = ["kms:CreateAlias"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = ["ec2.${data.aws_caller_identity.me.account_id}.amazonaws.com"]
      variable = "kms:ViaService"
    }
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.me.account_id]
      variable = "kms:CallerAccount"
    }
  }
}

resource "aws_kms_key" "cloudtrail" {
  count = local.deploy_cloudtrail ? 1 : 0

  is_enabled          = true
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_key_policy.json
}

resource "aws_kms_alias" "cloudtrail" {
  count = local.deploy_cloudtrail ? 1 : 0

  target_key_id = aws_kms_key.cloudtrail[0].id
  name          = "alias/${var.naming_prefix}-CloudTrail"
}

resource "aws_cloudtrail" "trail" {
  count = local.deploy_cloudtrail ? 1 : 0

  depends_on = [aws_sns_topic_policy.sns[0], aws_s3_bucket_policy.cloudtrail[0]]

  name                          = "${var.naming_prefix}-Trail"
  enable_logging                = true
  is_multi_region_trail         = local.is_multi_region
  include_global_service_events = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.cloudtrail[0].arn
  s3_bucket_name                = aws_s3_bucket.cloudtrail[0].id
  sns_topic_name                = aws_sns_topic.sns[0].id
}

resource "aws_sqs_queue" "sqs_cloudconnector" {
  name = "${var.naming_prefix}-CloudConnector"
}

resource "aws_sqs_queue" "sqs_cloudscanning" {
  name = "${var.naming_prefix}-CloudScanning"
}

data "aws_iam_policy_document" "sqs_cloudconnector" {
  statement {
    sid    = "Allow SNS to send messages"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "sqs:SendMessage",
      "sqs:SendMessageBatch"
    ]
    resources = [aws_sqs_queue.sqs_cloudconnector.arn]
  }
}

resource "aws_sqs_queue_policy" "sqs_cloudconnector" {
  policy    = data.aws_iam_policy_document.sqs_cloudconnector.json
  queue_url = aws_sqs_queue.sqs_cloudconnector.id
}

data "aws_iam_policy_document" "sqs_cloudscanning" {
  statement {
    sid    = "Allow SNS to send messages"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "sqs:SendMessage",
      "sqs:SendMessageBatch"
    ]
    resources = [aws_sqs_queue.sqs_cloudscanning.arn]
  }
}

resource "aws_sqs_queue_policy" "sqs_cloudscanning" {
  policy    = data.aws_iam_policy_document.sqs_cloudscanning.json
  queue_url = aws_sqs_queue.sqs_cloudscanning.id
}

resource "aws_sns_topic_subscription" "sqs_cloudconnector" {
  endpoint  = aws_sqs_queue.sqs_cloudconnector.arn
  protocol  = "sqs"
  topic_arn = local.deploy_cloudtrail ? aws_sns_topic.sns[0].arn : var.existing_cloudtrail_sns_topic
}

resource "aws_sns_topic_subscription" "sqs_cloudscanning" {
  endpoint  = aws_sqs_queue.sqs_cloudscanning.arn
  protocol  = "sqs"
  topic_arn = local.deploy_cloudtrail ? aws_sns_topic.sns[0].arn : var.existing_cloudtrail_sns_topic
}
