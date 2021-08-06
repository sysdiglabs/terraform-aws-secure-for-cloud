variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}


variable "cloudvision_organizational_setup" {
  type = object({
    is_organizational                 = bool
    org_cloudvision_member_account_id = string
  })
  default = {
    is_organizational                 = false
    org_cloudvision_member_account_id = null
  }
  description = "whether is_organizational setup is to be enabled. if true, cloudvision_member_account_id must be given, to enable reading permission"
  validation {
    condition     = var.cloudvision_organizational_setup.is_organizational == false || (var.cloudvision_organizational_setup.is_organizational == true && can(tostring(var.cloudvision_organizational_setup.org_cloudvision_member_account_id)))
    error_message = "If is_organizational=true, org_cloudvision_member_account_id must not be null."
  }
}


# --------------------
# cloudtrail configuration
# --------------------

variable "cloudtrail_org_is_multi_region_trail" {
  type        = bool
  default     = true
  description = "testing/economization purpose. true/false whether cloudtrail will ingest multiregional events"
}

variable "cloudtrail_org_kms_enable" {
  type        = bool
  default     = true
  description = "testing/economization purpose. true/false whether s3 should be encrypted"
}



#---------------------------------
# optionals - with defaults
#---------------------------------
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

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}
