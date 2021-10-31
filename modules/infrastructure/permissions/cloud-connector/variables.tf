variable "sfc_user_name" {
  type        = string
  description = "Name of the IAM user to provision permissions"
}

variable "cloudtrail_s3_bucket_arn" {
  type        = string
  description = "ARN of cloudtrail s3 bucket"
}

variable "cloudtrail_subscribed_sqs_arn" {
  type        = string
  description = "ARN of the cloudtrail subscribed sqs's"
}


#---------------------------------
# optionals - with default
#---------------------------------

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}
