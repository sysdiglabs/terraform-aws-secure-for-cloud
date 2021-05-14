variable "existing_cloudtrail_sns_topic" {
  type        = string
  default     = ""
  description = "Provide an existing CloudTrail SNS Topic, or leave it blank to let us to deploy the infrastructure required for running Sysdig for Cloud."
}

variable "multi_region_trail" {
  type        = bool
  default     = true
  description = "Specify if the cloud trail to create needs to be multi regional"
}

variable "cloudtrail_log_retention" {
  type        = number
  default     = 5
  description = "Days to keep logs from CloudTrail in S3 bucket."
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
