variable "organizational_setup" {
  type = object({
    is_organization_trail             = bool
    org_cloudvision_member_account_id = string
  })
  default = {
    is_organization_trail             = false
    org_cloudvision_member_account_id = null
  }
  description = "whether organization_trail setup is to be enabled. if true, cloudvision_member_account_id must be given, to enable reading permission"
  validation {
    condition     = var.organizational_setup.is_organization_trail == false || (var.organizational_setup.is_organization_trail == true && can(tostring(var.organizational_setup.org_cloudvision_member_account_id)))
    error_message = "If is_organization_trail=true, org_cloudvision_member_account_id must not be null."
  }
}


#---------------------------------
# optionals - with defaults
#---------------------------------
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
