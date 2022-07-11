locals {
  cross_account = data.aws_caller_identity.me.account_id != var.organizational_config.sysdig_secure_for_cloud_member_account_id
}


resource "aws_sns_topic_policy" "allow_cloudtrail_publish" {
  arn    = aws_sns_topic.cloudtrail.arn
  policy = data.aws_iam_policy_document.cloudtrail_sns.json
}


data "aws_iam_policy_document" "cloudtrail_sns" {
  statement {
    sid    = "AllowCloudtrailPublish"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.cloudtrail.arn]
  }


  # Organizational Requirements
  # note; this statement is required to be on the SNS creation, don't move to other module as policies cannot be overriten/exteneded after creation
  dynamic "statement" {
    for_each = var.is_organizational && local.cross_account ? [1] : []
    content {
      sid    = "AllowSysdigSecureForCloudSubscribe"
      effect = "Allow"
      principals {
        identifiers = ["arn:aws:iam::${var.organizational_config.sysdig_secure_for_cloud_member_account_id}:role/${var.organizational_config.organizational_role_per_account}"]
        type = "AWS"
      }
      actions   = ["sns:Subscribe"]
      resources = [aws_sns_topic.cloudtrail.arn]
    }
  }
}
