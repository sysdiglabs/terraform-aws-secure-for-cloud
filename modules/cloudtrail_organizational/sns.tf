resource "aws_sns_topic" "cloudtrail" {
  name = var.cloudtrail_name
  tags = var.tags
}

resource "aws_sns_topic_policy" "cloudtrail" {
  arn    = aws_sns_topic.cloudtrail.arn
  policy = data.aws_iam_policy_document.cloudtrail_sns.json

}


# --------------------------
# acl
# -------------------------
data "aws_iam_policy_document" "cloudtrail_sns" {
  statement {
    sid    = "AllowCloudtrailPublish"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.cloudtrail.arn]
  }

  statement {
    sid    = "AllowCloudvisionSubscribe"
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${var.cloudvision_account_id}:role/OrganizationAccountAccessRole"]
      type        = "AWS"
    }
    actions   = ["sns:Subscribe"]
    resources = [aws_sns_topic.cloudtrail.arn]
  }

  statement {
    sid     = "DenySubscribeIfNotCloudvisionVPC"
    effect  = "Deny"
    actions = ["sns:Subscribe"]
    principals {
      identifiers = ["sqs.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringNotEquals"
      values   = [var.cloudvision_vpc_id]
      variable = "aws:sourceVpce"
    }
    resources = [aws_sns_topic.cloudtrail.arn]
  }
}
