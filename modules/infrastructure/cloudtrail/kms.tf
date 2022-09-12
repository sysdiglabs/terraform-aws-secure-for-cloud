resource "aws_kms_key" "cloudtrail_kms" {
  count                   = local.create_kms_key ? 1 : 0
  is_enabled              = true
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.cloudtrail_kms[0].json
  deletion_window_in_days = 7

  tags = var.tags
}

resource "aws_kms_alias" "kms" {
  count         = local.create_kms_key ? 1 : 0
  target_key_id = aws_kms_key.cloudtrail_kms[0].id
  name          = "alias/${var.name}"
}

data "aws_iam_policy_document" "cloudtrail_kms" {
  count = local.create_kms_key ? 1 : 0
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      # identifiers = ["arn:aws:iam::${data.aws_caller_identity.me.account_id}:root"]
      identifiers = [data.aws_caller_identity.me.account_id]
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
    #    principals {
    #      identifiers = ["*"]
    #      type        = "AWS"
    #    }
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["kms:Decrypt", "kms:ReEncryptFrom"]
    resources = ["*"]
    #        condition {
    #          test     = "StringEquals"
    #          values   = [data.aws_caller_identity.me.account_id]
    #          variable = "kms:CallerAccount"
    #        }
    #        condition {
    #          test     = "StringLike"
    #          values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.me.account_id}:trail/*"]
    #          variable = "kms:EncryptionContext:aws:cloudtrail:arn"
    #        }
  }
}
