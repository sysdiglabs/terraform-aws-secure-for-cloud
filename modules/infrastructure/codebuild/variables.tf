variable "secure_api_token_secret_name" {
  type        = string
  description = "Sysdig Secure API token SSM parameter name"
}

#------------------------------
# optionals - with defaults
#------------------------------
variable "cloudwatch_log_retention" {
  type        = number
  default     = 30
  description = "Days to keep logs from builds"
}

variable "name" {
  type        = string
  default     = "sfc-codebuild"
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}
