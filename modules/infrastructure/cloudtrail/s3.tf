resource "aws_s3_bucket" "cloudtrail" {
  # AC_AWS_0214
  # Why: S3 bucket versioning is disabled
  #ts:skip=AC_AWS_0214 S3 is for testing purpose by the customer. In production S3 it's pretended to be provided by the customer with the logging related decisions taken by them as it has costs.
  # AC_AWS_0497
  # Why: S3 access logging is disabled
  #ts:skip=AC_AWS_0497 S3 is for testing purpose by the customer. In production S3 it's pretended to be provided by the customer with the logging related decisions taken by them as it has costs.
  bucket        = "${var.name}-${data.aws_caller_identity.me.account_id}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  rule {

    apply_server_side_encryption_by_default {
      sse_algorithm     = var.cloudtrail_kms_enable ? "aws:kms" : "AES256"
      kms_master_key_id = var.cloudtrail_kms_enable ? aws_kms_key.cloudtrail_kms[0].id : null
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    id     = "expire in ${var.s3_bucket_expiration_days} days"
    status = "Enabled"
    expiration {
      days = var.s3_bucket_expiration_days
    }
  }
}


resource "aws_s3_bucket_acl" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  acl    = "private"
}


# --------------------------
# iam, acl
# -------------------------

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket_policy.cloudtrail_s3]
  # https://github.com/hashicorp/terraform-provider-aws/issues/7628
}


resource "aws_s3_bucket_policy" "cloudtrail_s3" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_s3.json
}
data "aws_iam_policy_document" "cloudtrail_s3" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions = ["s3:PutObject"]
    condition {
      variable = "s3:x-amz-acl"
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
    }
    resources = ["${aws_s3_bucket.cloudtrail.arn}/AWSLogs/*"]
  }

  # S3 buckets should require requests to use Secure Socket Layer
  # [PCI.S3.5] This AWS control checks whether S3 buckets have policies that require requests to use Secure Socket Layer (SSL).
  statement {
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    actions   = ["s3:*"]
    resources = [
      aws_s3_bucket.cloudtrail.arn,
      "${aws_s3_bucket.cloudtrail.arn}/*"
    ]
    effect = "Deny"
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
