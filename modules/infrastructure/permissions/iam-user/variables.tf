#---------------------------------
# optionals - with defaults
#---------------------------------

variable "deploy_threat_detection" {
  type        = bool
  description = "true/false whether to provision cloud_connector permissions"
  default     = true
}

variable "deploy_image_scanning" {
  type        = bool
  description = "true/false whether to provision cloud_scanning permissions"
  default     = true
}


# permission defaults to all resources; ARN *

variable "cloudtrail_s3_bucket_arn" {
  type        = string
  description = "ARN of cloudtrail s3 bucket"
  default     = "*"
}

variable "cloudtrail_subscribed_sqs_arn" {
  type        = string
  description = "ARN of the cloudtrail subscribed sqs's"
  default     = "*"
}

variable "ssm_secure_api_token_arn" {
  type        = string
  description = "ARN of the security credentials for the secure_api_token "
  default     = "*"
}

variable "scanning_codebuild_project_arn" {
  type        = string
  description = "ARN of codebuild to launch the image scanning process"
  default     = "*"
}

#
# general
#

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}
