############################
# required
############################

variable "sysdig_secure_api_token" {
  type        = string
  sensitive   = true
  description = "Sysdig Secure API token"
}

variable "cloudtrail_sns_topic_arn" {
  type = string
  description = "SNS Topic ARN created by the CloudTrail module"
}

############################
# optionals - with default
############################

variable "cloudvision_product_tags"{
  type=map(string)
  default = {
    "product" = "cloudvision"
  }
}

variable "name" {
  type        = string
  description = "Name for the Cloud Vision deployment"
  default     = "cloudvision"
}

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "verify_ssl" {
  type = string
  default = "auto"
  description = "true | false to detetrmine ssl verification. default will set it to true only if sysdig_secure_endpoint is sysdig.com or sysdigcloud.com domain"
}