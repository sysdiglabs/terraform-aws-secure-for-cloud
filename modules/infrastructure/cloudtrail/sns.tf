resource "aws_sns_topic" "cloudtrail" {
  name = var.name
  tags = var.tags
}



# --------------------------
# acl
# -------------------------
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
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.cloudtrail.arn]
  }
}


resource "aws_sns_topic_policy" "allow_cloudvision_subscribe" {
  count  = var.organizational_setup.is_organizational ? 1 : 0
  arn    = aws_sns_topic.cloudtrail.arn
  policy = data.aws_iam_policy_document.cloudtrail_cloudvision[0].json
}

data "aws_iam_policy_document" "cloudtrail_cloudvision" {
  count = var.organizational_setup.is_organizational ? 1 : 0
  statement {
    sid    = "AllowCloudvisionSubscribe"
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${var.organizational_setup.org_cloudvision_member_account_id}:role/OrganizationAccountAccessRole"]
      type        = "AWS"
    }
    actions   = ["sns:Subscribe"]
    resources = [aws_sns_topic.cloudtrail.arn]
  }
}
