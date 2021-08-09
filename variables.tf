variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}


variable "cloudvision_organizational_setup" {
  type = object({
    is_organizational                 = bool
    connector_ecs_task_role_name      = string
    org_cloudvision_member_account_id = string
    org_cloudvision_role              = string
  })
  default = {
    is_organizational                 = false
    connector_ecs_task_role_name      = "connector-ECSTaskRole"
    org_cloudvision_member_account_id = null
    org_cloudvision_role              = null
  }

  description = <<-EOT
    whether organizational setup is to be enabled. if true,
    <ul><li>cloudvision_member_account_id must be given, to enable reading permission,</li><li>org_cloudvision_role for cloud-connect assumeRole in order to read cloudtrail s3 events</li><li>and ecs cluster task role name which has been granted assumeRole trusted relationship</li></ul>
  EOT

  validation {
    condition     = var.cloudvision_organizational_setup.is_organizational == false || (var.cloudvision_organizational_setup.is_organizational == true && can(tostring(var.cloudvision_organizational_setup.org_cloudvision_member_account_id)))
    error_message = "If is_organizational=true, org_cloudvision_member_account_id must not be null."
  }

  validation {
    condition     = var.cloudvision_organizational_setup.is_organizational == false || (var.cloudvision_organizational_setup.is_organizational == true && can(tostring(var.cloudvision_organizational_setup.org_cloudvision_role)))
    error_message = "If is_organizational=true, org_cloudvision_role must not be null."
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
