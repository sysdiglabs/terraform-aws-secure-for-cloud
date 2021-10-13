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

variable "scanning_build_project_arn" {
  type        = string
  description = "ARN of codebuild to launch the image scanning process"
}

#---------------------------------
# optionals - with default
#---------------------------------

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}


variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}
