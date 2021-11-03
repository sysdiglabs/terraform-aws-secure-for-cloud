variable "cloudtrail_s3_name" {
  type = string
}


#variable "sysdig_secure_for_cloud_member_account_id" {
#  type        = string
#  description = "Permission provisioning. Organizational member account where Sysdig Secure for Cloud workload will be deployed."
#}
#
#---------------------------------
# optionals - with defaults
#---------------------------------

variable "event_notification_path_filter" {
  type    = string
  default = "*"
}

#variable "organizational_member_default_admin_role" {
#  type        = string
#  default     = "OrganizationAccountAccessRole"
#  description = "Default role created by AWS for managed-account users to be able to admin member accounts.<br/>https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html"
#}
#
##
## cloudtrail configuration
##
#
#variable "cloudtrail_is_multi_region_trail" {
#  type        = bool
#  default     = true
#  description = "true/false whether cloudtrail will ingest multiregional events. testing/economization purpose."
#}
#
#variable "cloudtrail_kms_enable" {
#  type        = bool
#  default     = true
#  description = "true/false whether cloudtrail delivered events to S3 should persist encrypted"
#}
#


##
## general
##
#
variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "Default region for resource creation in both organization master and secure-for-cloud member account"
}


variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}


variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}
