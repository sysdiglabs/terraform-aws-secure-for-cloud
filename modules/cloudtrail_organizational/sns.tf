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
    sid    = "AllowECSTaskService"
    effect = "Allow"
    //    principals {
    //      identifiers = [""] //FIXME. unharcode, but may produce cyclic. can be service too with only cloudvision account
    //      type        = "AWS"
    //    }
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sns:Subscribe"]
    resources = [aws_sns_topic.cloudtrail.arn]
  }
}
