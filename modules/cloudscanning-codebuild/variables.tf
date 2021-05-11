
variable "log_retention" {
  type        = number
  default     = 30
  description = "Days to keep logs from builds"
}

variable "ssm_endpoint" {
  type        = string
  description = "Name of the parameter in SSM containing the Sysdig Secure Endpoint URL"
}

variable "ssm_token" {
  type        = string
  description = "Name of the parameter in SSM containing the Sysdig Secure API Token"
}

variable "verify_ssl" {
  type        = bool
  default     = true
  description = "Whether to verify the SSL certificate of the endpoint or not"
}

variable "naming_prefix" {
  type        = string
  default     = "SysdigCloud"
  description = "Prefix for resource names. Use the default unless you need to install multiple instances, and modify the deployment at the main account accordingly"

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]+$", var.naming_prefix)) && length(var.naming_prefix) > 1 && length(var.naming_prefix) <= 64
    error_message = "Must enter a naming prefix up to 64 alphanumeric characters."
  }
}
