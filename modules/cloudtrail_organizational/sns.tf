resource "aws_sns_topic" "cloudtrail" {
  name = var.cloudtrail_name
  tags = var.tags
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
      identifiers = ["*"] // FIXME, why does it not work with Service:ecs-tasks.amazonaws.com?
      type        = "AWS"
    }
    actions   = ["sns:Subscribe"]
    resources = [aws_sns_topic.cloudtrail.arn]
  }
}
