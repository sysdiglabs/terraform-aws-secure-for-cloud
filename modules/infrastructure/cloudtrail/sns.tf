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
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.cloudtrail.arn]
  }


  dynamic "statement" {
    for_each = var.is_organizational ? [1] : []
    content {
      sid    = "AllowSysdigSecureForCloudSubscribe"
      effect = "Allow"
      principals {
        identifiers = ["arn:aws:iam::${var.organizational_config.sysdig_secure_for_cloud_member_account_id}:role/${var.organizational_config.organizational_role_per_account}"]
        type        = "AWS"
      }
      actions   = ["sns:Subscribe"]
      resources = [aws_sns_topic.cloudtrail.arn]
    }
  }
}
