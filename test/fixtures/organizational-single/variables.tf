variable "sysdig_secure_api_token" {
  type        = string
  sensitive   = true
  description = "Sysdig secure api token"
}
variable "sysdig_secure_for_cloud_member_account_id" {
  type        = string
  description = "organizational member account where the secure-for-cloud workload is going to be deployed"
}




variable "name" {
  type        = string
  description = "Name is the prefix used in the resources will be created"
  default     = "sfctest-org-ecs-single"
}

variable "region" {
  type        = string
  description = "Region to be deployed"
  default     = "eu-west-3"
}

variable "sysdig_secure_url" {
  type        = string
  description = "Sysdig secure endpoint"
  default     = "https://secure.sysdig.com"
}
