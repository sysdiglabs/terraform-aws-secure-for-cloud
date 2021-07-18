############################
# required
############################

variable "sysdig_secure_api_token" {
  type        = string
  sensitive   = true
  description = "Sysdig Secure API token"
}

variable "cloudtrail_sns_topic_arn" {
  type        = string
  description = "CloudTrail module created SNS Topic ARN"
}

variable "services_assume_role_arn" {
  type        = string
  description = "Cloudvision service required assumeRole arn"
}

############################
# optionals - with default
############################

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}

variable "name" {
  type        = string
  description = "Name for the Cloud Vision deployment"
  default     = "sysdig-cloudvision"
}

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "verify_ssl" {
  type        = string
  default     = "auto"
  description = "true/false to determine ssl verification. default will set it to true only if sysdig_secure_endpoint is sysdig.com or sysdigcloud.com domain"
}
