#---------------------------------
# optionals - with defaults
#---------------------------------

variable "enable_cloud_connector" {
  type        = bool
  description = "true/false whether to provision cloud_connector permissions"
  default     = true
}

variable "enable_cloud_scanning" {
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

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "Default region for resource creation in both organization master and secure-for-cloud member account"
}


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
