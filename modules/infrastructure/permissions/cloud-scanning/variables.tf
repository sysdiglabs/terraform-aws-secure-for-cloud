variable "sfc_user_name" {
  type        = string
  description = "Name of the IAM user to provision permissions"
}

variable "cloudtrail_subscribed_sqs_arn" {
  type        = string
  description = "ARN of the cloudtrail subscribed sqs's"
}


variable "scanning_codebuild_project_arn" {
  type        = string
  description = "ARN of codebuild to launch the image scanning process"
}

variable "use_scanning_v2" {
  type        = bool
  description = "true/false whether use inline scanner or not"
  default     = false
}

#---------------------------------
# optionals - with default
#---------------------------------

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}
