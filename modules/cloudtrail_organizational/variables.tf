variable "cloudvision_account_id" {
  type        = string
  description = "cloudvision member account id"
}


#---------------------------------
# optionals - with defaults
#---------------------------------
variable "cloudtrail_name" {
  type        = string
  default     = "sysdig-cloudvision"
  description = "CloudTrail name"
}

variable "s3_bucket_name" {
  type        = string
  default     = "sysdig-cloudvision"
  description = "S3 bucket name that will be created with the CloudTrail resources, where the logs will be saved."
}

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}

variable "s3_bucket_expiration_days" {
  type        = number
  default     = 5
  description = "Number of days that the logs will persist in the bucket"
}

variable "cloudtrail_kms_enable" {
  type        = bool
  default     = true
  description = "true/false whether s3 should be encrypted"
}

variable "is_multi_region_trail" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail will ingest multiregional events"
}
