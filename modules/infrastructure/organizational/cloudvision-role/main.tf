resource "aws_iam_role" "cloudvision_role" {
  name               = "${var.name}-SysdigCloudVisionRole"
  assume_role_policy = data.aws_iam_policy_document.cloudvision_role_trusted.json
  tags               = var.tags
}

# ---------------------------------------------
# ecs task role 1/2
# trust ecs-task-role identifier to assumeRole
# ---------------------------------------------

data "aws_iam_role" "ecs_task_role" {
  provider = aws.member
  name     = var.cloudconnect_ecs_task_role_name
}

data "aws_iam_policy_document" "cloudvision_role_trusted" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        data.aws_iam_role.ecs_task_role.arn
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}


# ---------------------------------------------
# ecs task role 2/2 (resource)
# enable ecs-task resource to assumeRole
# ---------------------------------------------

resource "aws_iam_role_policy" "enable_assume_cloudvision_role" {
  provider = aws.member
  name     = "${var.name}-EnableCloudvisionRole"

  role   = var.cloudconnect_ecs_task_role_name
  policy = data.aws_iam_policy_document.enable_assume_cloudvision_role.json
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



# ------------------------------
# enable cloudtrail_s3 RO access
# ------------------------------

resource "aws_iam_role_policy" "cloudvision_role_s3" {
  name   = "${var.name}-AllowCloudtrailS3Policy"
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
