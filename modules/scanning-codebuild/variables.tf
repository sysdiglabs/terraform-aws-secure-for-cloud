variable "name" {
  type        = string
  default     = "cloud-scanning-codebuild"
  description = "Name for the Cloud Scanning CodeBuild deployment"
}

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
