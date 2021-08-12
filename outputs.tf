output "cloudtrail_s3_arn" {
  value       = module.cloudtrail.s3_bucket_arn
  description = "sydig-cloudvision cloudtrail s3 arn, required for organizational use case, in order to give proper permissions to cloudconnector role to assume"
}
