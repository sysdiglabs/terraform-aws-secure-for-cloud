variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}


variable "cloudvision_member_account_id" {
  type        = string
  description = "the account_id **within the organization** to be used as cloudvision account"
}


#------------------------------
# optionals - with defaults
#------------------------------


#
# cloudtrail configuration
#

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


#
# misc
#

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "Default region for resource creation in both organization master and cloudvision member account"
}

variable "connector_ecs_task_role_name" {
  type        = string
  default     = "sysdig-cloudvision-connector-ECSTaskRole"
  description = "Name for the ecs task role. This is only required to resolve cyclic dependency with organizational approach"
}

variable "name" {
  type        = string
  default     = "sysdig-cloudvision"
  description = "Name to be assigned to all child resources"
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
