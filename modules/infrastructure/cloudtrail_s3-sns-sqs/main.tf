# --------------------------------------------
# cloudtrail_s3 bucket sns event notification
# --------------------------------------------

data "aws_s3_bucket" "cloudtrail_s3" {
  bucket = var.cloudtrail_s3_name
}


locals {
  s3_sns_name = "${var.name}-s3-sns"
}


resource "aws_sns_topic" "s3_sns" {
  # AC_AWS_0502
  # Why: Encrypt SNS with KMS
  #ts:skip=AC_AWS_0502 Don't encrypt as far as SNS can be provided by customer
  name   = local.s3_sns_name
  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": { "Service": "s3.amazonaws.com" },
        "Action": "SNS:Publish",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${data.aws_s3_bucket.cloudtrail_s3.arn}"}
        },
        "Resource": "arn:aws:sns:*:*:${local.s3_sns_name}"
    }]
}
POLICY
  tags   = var.tags
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.cloudtrail_s3.id

  topic {
    id            = "${var.name}-notif"
    topic_arn     = aws_sns_topic.s3_sns.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = var.s3_event_notification_filter_prefix
  }
}

# --------------------
# sqs
# --------------------
module "cloudtrail_s3_sns_sqs" {
  source             = "../sqs-sns-subscription"
  name               = "${var.name}-s3-sqs"
  cloudtrail_sns_arn = aws_sns_topic.s3_sns.arn

  tags = var.tags
}
