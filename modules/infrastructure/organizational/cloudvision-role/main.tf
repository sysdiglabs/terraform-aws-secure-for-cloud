#
# empty provider to pass `terraform validate`
# will be overrided by parent in real execution
# https://github.com/hashicorp/terraform/issues/21416
#
provider "aws" {
  alias = "member"
}



resource "aws_iam_role" "cloudvision_role" {
  count              = var.create ? 1 : 0
  name               = "SysdigCloudVisionRole"
  assume_role_policy = element(data.aws_iam_policy_document.cloudvision_role_trusted, 0).json
  tags               = var.tags
}

data "aws_iam_policy_document" "cloudvision_role_trusted" {
  count = var.create ? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        var.cloudconnect_ecs_task_role_arn
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role_policy" "cloudvision_role_s3" {
  count  = var.create ? 1 : 0
  name   = "AllowCloudtrailS3Policy"
  role   = aws_iam_role.cloudvision_role[0].id
  policy = data.aws_iam_policy_document.cloudvision_role_s3[0].json
}
data "aws_iam_policy_document" "cloudvision_role_s3" {
  count = var.create ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [
      var.cloudtrail_s3_arn,
      "${var.cloudtrail_s3_arn}/*"
    ]
  }
}


# ------------------------------
# ecs task role
# ------------------------------
resource "aws_iam_role_policy" "enable_assume_cloudvision_role" {
  count    = var.create ? 1 : 0
  provider = aws.member
  name     = "${var.name}-EnableCloudvisionRole"
  role     = var.cloudconnect_ecs_task_role_name
  policy   = data.aws_iam_policy_document.enable_assume_cloudvision_role[0].json
}
data "aws_iam_policy_document" "enable_assume_cloudvision_role" {
  count = var.create ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [aws_iam_role.cloudvision_role[0].arn]
  }
}
