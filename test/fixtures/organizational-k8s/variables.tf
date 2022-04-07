variable "cloudtrail_s3_name" {
  type        = string
  description = "Name of the Cloudtrail S3 bucket"
}

variable "sysdig_secure_api_token" {
  type        = string
  sensitive   = true
  description = "Sysdig secure api token"
}



#---------------------------------
# provide variables for testing
#---------------------------------

variable "s3_event_notification_filter_prefix" {
  type        = string
  default     = ""
  description = "S3 Path filter prefix for event notification. Limit the notifications to objects with key starting with specified characters"
}

variable "org_profile" {
  type    = string
  default = ""
}

variable "cloudnative_profile" {
  type    = string
  default = ""
}

variable "org_accessKeyId" {
  type      = string
  sensitive = true
  default   = ""
}

variable "org_secretAccessKey" {
  type      = string
  sensitive = true
  default   = ""
}

variable "cloudnative_accessKeyId" {
  type      = string
  sensitive = true
  default   = ""
}

variable "cloudnative_secretAccessKey" {
  type      = string
  sensitive = true
  default   = ""
}



#---------------------------------
# optionals - with defaults
#---------------------------------

variable "sysdig_secure_url" {
  type        = string
  description = "Sysdig secure endpoint"
  default     = "https://secure.sysdig.com"
}

variable "name" {
  type        = string
  description = "Name is the prefix used in the resources will be created"
  default     = "sfc-tests-kitchen"
}

variable "region" {
  type        = string
  description = "Region in which the cloudtrail and EKS are deployed. Currently same region is required"
  default     = "eu-central-1"
}
