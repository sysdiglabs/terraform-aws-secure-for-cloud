data "aws_caller_identity" "me" {}

resource "aws_s3_bucket" "s3_config_bucket" {
  bucket        = "${var.name}-${data.aws_caller_identity.me.account_id}-config"
  acl           = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
  tags = var.tags
}


# --------------------------
# iam, acl
# -------------------------

resource "aws_s3_bucket_public_access_block" "s3_config_bucket" {
  bucket = aws_s3_bucket.s3_config_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.allow_cloudvision_role] # https://github.com/hashicorp/terraform-provider-aws/issues/7628
}

resource "aws_s3_bucket_policy" "allow_cloudvision_role" {
  bucket = aws_s3_bucket.s3_config_bucket.id
  policy = data.aws_iam_policy_document.allow_cloudvision_role.json
}

data "aws_iam_policy_document" "allow_cloudvision_role" {
  statement {
    sid    = "Allow Cloudvision role"
    effect = "Allow"
    principals {
      identifiers = [var.services_assume_role_arn]
      type        = "AWS"
    }
    actions = [
      "s3:Get*",
      "s3:List*",
    ]
    resources = [aws_s3_bucket.s3_config_bucket.arn]
  }
}


# --------------------------
# vpc
# -------------------------
data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id             = var.services_vpc_id
  service_name       = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type  = "Interface"
  security_group_ids = [var.services_sg_id]
  subnet_ids         = var.services_vpc_private_subnets
  //  private_dns_enabled = true
  tags = var.tags
}