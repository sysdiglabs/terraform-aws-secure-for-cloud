variable "secure_api_token_secret_name" {
  type        = string
  description = "Sysdig Secure API token SSM parameter name"
}

variable "cloudtrail_s3_bucket_arn" {
  type        = string
  description = "ARN of cloudtrail s3 bucket"
}

variable "cloudtrail_sns_subscribed_sqs_arns" {
  type        = list(string)
  description = "List of ARNs of the cloudtrail-sns subscribed sqs's"
}

#---------------------------------
# optionals - with default
#---------------------------------

variable "name" {
  type        = string
  description = "Name for the Cloud Vision deployment"
  default     = "sysdig-secure-for-cloud"
}


variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}
