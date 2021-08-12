<<<<<<< HEAD
variable "organizational_setup" {
  type = object({
    is_organizational                 = bool
    org_cloudvision_member_account_id = string
  })
  default = {
    is_organizational                 = false
    org_cloudvision_member_account_id = null
  }
  description = "whether organization_trail setup is to be enabled. if true, cloudvision_member_account_id must be given, to enable reading permission"
  validation {
    condition     = var.organizational_setup.is_organizational == false || (var.organizational_setup.is_organizational == true && can(tostring(var.organizational_setup.org_cloudvision_member_account_id)))
    error_message = "If is_organizational=true, org_cloudvision_member_account_id must not be null."
  }
}

=======
>>>>>>> master

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
