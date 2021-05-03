variable "naming_prefix" {
  type        = string
  default     = "SysdigCloud"
  description = "Prefix for resource names. Use the default unless you need to install multiple instances, and modify the deployment at the main account accordingly"

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]+$", var.naming_prefix)) && length(var.naming_prefix) > 1 && length(var.naming_prefix) <= 64
    error_message = "Must enter a naming prefix up to 64 alphanumeric characters."
  }
}

variable "trail_accounts_and_regions" {
  type = list(object({
    account_id = string
    region     = string
  }))
  default     = []
  description = "A list of child AWS accounts and regions where CloudTrail is enabled."
}

variable "bench_accounts_and_regions" {
  type = list(object({
    account_id = string
    region     = string
  }))
  default     = []
  description = "A list of child AWS accounts and regions where benchmarks will run."
}

variable "cloudconnector_deploy" {
  type    = bool
  default = true
}

variable "cloudbench_deploy" {
  type    = bool
  default = true
}

variable "ecr_image_scanning_deploy" {
  type    = bool
  default = true
}

variable "ecs_image_scanning_deploy" {
  type    = bool
  default = true
}

variable "existing_ecs_cluster" {
  type        = string
  default     = ""
  description = "Use an existing ECS cluster"
}

variable "existing_ecs_cluster_vpc" {
  type        = string
  default     = ""
  description = "Use an existing ECS cluster VPC"
}

variable "existing_ecs_cluster_private_subnets" {
  type        = list(string)
  default     = []
  description = "Use the existing ECS cluster private subnets"
}

variable "sysdig_secure_api_token" {
  type        = string
  sensitive   = true
  description = "Sysdig Secure API token"
}

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

