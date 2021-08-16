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
  default     = "CloudVision"
  description = "Name for the Cloud Vision deployment"
}

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}
