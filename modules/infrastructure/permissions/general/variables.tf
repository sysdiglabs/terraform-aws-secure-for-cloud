variable "sfc_user_name" {
  type        = string
  description = "Name of the IAM user to provision permissions"
}

variable "secure_api_token_secret_arn" {
  type        = string
  description = "ARN of Sysdig Secure API token SSM parameter"
}

#---------------------------------
# optionals - with default
#---------------------------------

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}
