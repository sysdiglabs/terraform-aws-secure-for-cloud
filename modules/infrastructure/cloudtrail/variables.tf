#---------------------------------
# optionals - with defaults
#---------------------------------

#
# module composition
#

variable "is_organizational" {
  type        = bool
  default     = false
  description = "whether secure-for-cloud should be deployed in an organizational setup"
}


variable "organizational_config" {
  type = object({
    sysdig_secure_for_cloud_member_account_id = string
    organizational_role_per_account           = string
  })
  default = {
    sysdig_secure_for_cloud_member_account_id = null
    organizational_role_per_account           = null
  }
  description = <<-EOT
    organizational_config. following attributes must be given
    <ul><li>`sysdig_secure_for_cloud_member_account_id` to enable reading permission</li>
    <li>`organizational_role_per_account` to enable SNS topic subscription. by default "OrganizationAccountAccessRole"</li></ul>
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
# general
#

variable "name" {
  type        = string
  default     = "sfc"
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}
