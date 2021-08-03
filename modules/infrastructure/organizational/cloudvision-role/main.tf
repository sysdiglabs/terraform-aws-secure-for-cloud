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
        var.cloudconnect_ecs_task_role_arn
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role_policy" "cloudvision_role_s3" {
  name   = "AllowCloudtrailS3Policy"
  role   = aws_iam_role.cloudvision_role.id
  policy = data.aws_iam_policy_document.cloudvision_role_s3.json
}
data "aws_iam_policy_document" "cloudvision_role_s3" {
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
  provider = aws.cloudvision
  name     = "${var.name}-EnableCloudvisionRole"
  role     = var.cloudconnect_ecs_task_role_name
  policy   = data.aws_iam_policy_document.enable_assume_cloudvision_role.json
}
data "aws_iam_policy_document" "enable_assume_cloudvision_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [aws_iam_role.cloudvision_role.arn]
  }
}
