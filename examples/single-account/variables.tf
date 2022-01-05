variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}


#---------------------------------
# optionals - with defaults
#---------------------------------


#
# cloudtrail configuration
#
variable "cloudtrail_sns_arn" {
  type        = string
  default     = "create"
  description = "ARN of a pre-existing cloudtrail_sns. If it does not exist, it will be inferred from created cloudtrail"
}

variable "cloudtrail_is_multi_region_trail" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail will ingest multiregional events"
}

variable "cloudtrail_kms_enable" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail delivered events to S3 should persist encrypted"
}

#
# benchmark configuration
#

variable "deploy_benchmark" {
  type        = bool
  description = "Whether to deploy or not the cloud benchmarking"
  default     = true
}

variable "benchmark_regions" {
  type        = list(string)
  description = "List of regions in which to run the benchmark. If empty, the task will contain all aws regions by default."
  default     = []
}


#
# ecs vpc configuration
#
variable "ecs_ecs_vpc_region_azs" {
  type        = list(string)
  description = "Explicit list of availability zones for ECS VPC creation. eg: [\"apne1-az1\", \"apne1-az2\"]. If left empty it will be defaulted to two from the default datasource"
  default     = []
}



#
# general
#
variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}
