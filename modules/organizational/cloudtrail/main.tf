data "aws_caller_identity" "me" {}

##########################################
# S3 bucket
##########################################
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${var.s3_bucket_name}-nonrandom"
  acl           = "private"
  force_destroy = true

  lifecycle_rule {
    enabled = true
    expiration {
      days = var.s3_bucket_expiration_days
    }
  }
  tags = var.cloudvision_product_tags
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_s3.json
}

data "aws_iam_policy_document" "cloudtrail_s3" {

  statement {
    sid       = "AWSCloudTrailAclCheck20150319"
    actions   = ["s3:GetBucketAcl"]
    effect    = "Allow"
    resources = [aws_s3_bucket.cloudtrail.arn]
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
  }
  statement {
    sid     = "AWSCloudTrailWrite20150319"
    actions = ["s3:PutObject"]
    effect  = "Allow"

    resources = ["${aws_s3_bucket.cloudtrail.arn}/AWSLogs/*"]
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


##########################################
# SNS
##########################################
resource "aws_sns_topic" "cloudtrail" {
  name = var.cloudtrail_name
  tags = var.cloudvision_product_tags
}

resource "aws_sns_topic_policy" "cloudtrail" {
  arn    = aws_sns_topic.cloudtrail.arn
  policy = data.aws_iam_policy_document.cloudtrail_sns.json

}

data "aws_iam_policy_document" "cloudtrail_sns" {
  statement {
    sid    = "1"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.cloudtrail.arn]
  }

  statement {
    sid    = "2"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["SNS:Subscribe"]
    resources = [aws_sns_topic.cloudtrail.arn]
  }
}


##########################################
# cloudtrail
##########################################
resource "aws_cloudtrail" "cloudtrail" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  enable_logging                = true
  is_multi_region_trail         = true
  include_global_service_events = true
  is_organization_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  sns_topic_name                = aws_sns_topic.cloudtrail.id
  tags                          = var.cloudvision_product_tags
}



##########################################
# ksm
##########################################
resource "aws_kms_key" "cloudtrail" {
  is_enabled          = true
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.cloudtrail_kms.json
  tags                = var.cloudvision_product_tags
}


resource "aws_kms_alias" "cloudtrail" {
  target_key_id = aws_kms_key.cloudtrail.id
  name          = "alias/${var.cloudtrail_name}"
}


data "aws_iam_policy_document" "cloudtrail_kms" {
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

  statement {
    sid    = "Enable cross account log decryption"
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
}
