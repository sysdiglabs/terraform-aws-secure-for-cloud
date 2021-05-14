variable "naming_prefix" {
  type        = string
  default     = "SysdigCloud"
  description = "Prefix for resource names. Use the default unless you need to install multiple instances, and modify the deployment at the main account accordingly"

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]+$", var.naming_prefix)) && length(var.naming_prefix) > 1 && length(var.naming_prefix) <= 64
    error_message = "Must enter a naming prefix up to 64 alphanumeric characters."
  }
}

variable "main_account_id" {
  type        = string
  description = "ID of the AWS account where the Sysdig for Cloud components will be deployed"

  validation {
    condition     = can(regex("^\\d{12}$", var.main_account_id))
    error_message = "Must enter a valid AWS account ID (12 digits)."
  }
}

variable "cloudconnector_deploy" {
  type        = bool
  default     = true
  description = "Whether to deploy or not the Cloud Connector component"
}

variable "cloudbench_deploy" {
  type        = bool
  default     = true
  description = "Whether to deploy or not the Cloud Bench component"
}

variable "cloudscanning_deploy" {
  type        = bool
  default     = true
  description = "Whether to deploy or not the Cloud Scanning component"
}

