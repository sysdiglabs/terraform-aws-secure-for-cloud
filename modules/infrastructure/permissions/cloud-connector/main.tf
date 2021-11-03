resource "aws_iam_user_policy" "cloud_connector" {
  name   = "${var.name}-cc"
  user   = data.aws_iam_user.this.user_name
  policy = data.aws_iam_policy_document.cloud_connector.json
}

data "aws_iam_policy_document" "cloud_connector" {
  statement {
    sid    = "AllowReadCloudtrailS3"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"
      # TODO. scanning, only when used with ECS mode
      #      "s3:Put*",
      #      "s3:Head",
    ]
    resources = [
      var.cloudtrail_s3_bucket_arn,
      "${var.cloudtrail_s3_bucket_arn}/AWSLogs/*"
    ]
  }


  statement {
    sid    = "AllowReadWriteCloudtrailSubscribedSQS"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch"
    ]
    resources = [var.cloudtrail_subscribed_sqs_arn]
  }


  statement {
    sid    = "AllowReadSecurityHub"
    effect = "Allow"
    actions = [
      "securityhub:GetFindings",
      "securityhub:BatchImportFindings",
    ]
    resources = ["arn:aws:securityhub:${data.aws_region.this.name}::product/sysdig/sysdig-cloud-connector"]
    # TODO. make an input-var out of this
  }


  statement {
    sid    = "AllowCloudwatchLogManagement"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
    # TODO. make an input-var out of this. make it more specific "arn:aws:logs:eu-central-1:522353683035:log-group:test:*"
  }
}
