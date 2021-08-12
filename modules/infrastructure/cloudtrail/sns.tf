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
<<<<<<< HEAD
  
  dynamic "statement" {
    for_each = var.organizational_setup.is_organizational ? [1] : []
=======

  dynamic "statement" {
    for_each = var.is_organizational ? [1] : []
>>>>>>> master
    content {
      sid    = "AllowCloudvisionSubscribe"
      effect = "Allow"
      principals {
<<<<<<< HEAD
        identifiers = ["arn:aws:iam::${var.organizational_setup.org_cloudvision_member_account_id}:role/OrganizationAccountAccessRole"]
=======
        identifiers = ["arn:aws:iam::${var.organizational_config.cloudvision_member_account_id}:role/OrganizationAccountAccessRole"]
>>>>>>> master
        type        = "AWS"
      }
      actions   = ["sns:Subscribe"]
      resources = [aws_sns_topic.cloudtrail.arn]
    }
  }
}
