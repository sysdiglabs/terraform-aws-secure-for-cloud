output "cloudtrail_s3_arn" {
  value       = module.cloudtrail.s3_bucket_arn
  description = "cloudtrail s3 arn"
}
