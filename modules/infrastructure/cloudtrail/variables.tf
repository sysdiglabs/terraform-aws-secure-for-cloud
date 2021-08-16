#---------------------------------
# optionals - with defaults
#---------------------------------

#
# module composition
#

variable "is_organizational" {
  type        = bool
  default     = false
  description = "whether cloudvision should be deployed in an organizational setup"
}


variable "organizational_config" {
  type = object({
    cloudvision_member_account_id = string
  })
  default = {
    cloudvision_member_account_id = null
  }
  description = <<-EOT
    oragnizational_config. following attributes must be given
    <ul><li>`cloudvision_member_account_id` to enable reading permission</ul>
  EOT
}

#
# module config
#

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


#
# misc
#

variable "name" {
  type        = string
  default     = "sysdig-cloudvision"
  description = "Name to be assigned to all child resources"
}

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}
