locals {
  # We don't create the KMS key when an existing KMS key ARN is provided
  create_kms_key = var.cloudtrail_kms_enable && (var.cloudtrail_kms_arn != null || var.cloudtrail_kms_arn != "")
}
