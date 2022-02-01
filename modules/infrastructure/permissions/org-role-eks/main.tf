resource "aws_iam_role" "secure_for_cloud_role" {
  name               = "${var.name}-SysdigSecureForCloudRole"
  assume_role_policy = data.aws_iam_policy_document.sysdig_secure_for_cloud_role_trusted.json
  tags               = var.tags
}

data "aws_iam_policy_document" "sysdig_secure_for_cloud_role_trusted" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        var.user_arn
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

# ------------------------------
# enable cloudtrail_s3 RO access
# ------------------------------

resource "aws_iam_role_policy" "sysdig_secure_for_cloud_role_s3" {
  count  = var.deploy_threat_detection ? 1 : 0
  name   = "${var.name}-AllowCloudtrailS3Policy"
  role   = aws_iam_role.secure_for_cloud_role.id
  policy = data.aws_iam_policy_document.sysdig_secure_for_cloud_role_s3[0].json
}
data "aws_iam_policy_document" "sysdig_secure_for_cloud_role_s3" {
  count = var.deploy_threat_detection ? 1 : 0
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
# enable image-scanning on member-account repositories
# ------------------------------
resource "aws_iam_role_policy" "sysdig_secure_for_cloud_role_assume_role" {
  count  = var.deploy_image_scanning ? 1 : 0
  name   = "${var.name}-AllowAssumeRoleInChildAccounts"
  role   = aws_iam_role.secure_for_cloud_role.id
  policy = data.aws_iam_policy_document.sysdig_secure_for_cloud_role_assume_role[0].json
}
data "aws_iam_policy_document" "sysdig_secure_for_cloud_role_assume_role" {
  count = var.deploy_image_scanning ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      "arn:aws:iam::*:role/${var.organizational_role_per_account}"
    ]
  }
}
