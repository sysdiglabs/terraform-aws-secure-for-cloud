resource "aws_iam_role" "cloudvision_role" {
  name               = "SysdigCloudVisionRole"
  assume_role_policy = data.aws_iam_policy_document.cloud_vision_role_trusted.json
  tags               = var.tags
}
data "aws_iam_policy_document" "cloud_vision_role_trusted" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.org_cloudvision_account_id}:role/sysdig-cloudvision-cloudconnector-ECSTaskRole"
      ]
    }

    # enable use OrganizationalRole as TaskExecution role for ECS Task
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role_policy" "cloudtrail_s3" {
  name   = "AllowCloudtrailS3Policy"
  role   = aws_iam_role.cloudvision_role.id
  policy = data.aws_iam_policy_document.cloudtrail_s3.json
}
data "aws_iam_policy_document" "cloudtrail_s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [
      module.cloudtrail_organizational.s3_bucket_arn,
      "${module.cloudtrail_organizational.s3_bucket_arn}/*"
    ]
  }
}
