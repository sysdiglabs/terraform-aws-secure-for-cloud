#---------------------------------
# optionals - with defaults
#---------------------------------

#
# cloudtrail configuration
#

variable "cloudtrail_sns_arn" {
  type        = string
  default     = "create"
  description = "ARN of a pre-existing cloudtrail_sns. If defaulted, a new cloudtrail will be created. If specified, deployment region must match Cloudtrail S3 bucket region"
}

variable "cloudtrail_is_multi_region_trail" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail will ingest multiregional events. testing/economization purpose. "
}

variable "cloudtrail_kms_enable" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail delivered events to S3 should persist encrypted. If `var.cloudtrail_kms_arn` is set, then the pre-existing KMS key will be used, otherwise a new KMS key will be created"
}

variable "cloudtrail_kms_arn" {
  type        = string
  default     = null
  description = "When `var.cloudtrail_kms_enable` is set to true, ARN of a pre-existing KMS key for encrypting the Cloudtrail logs"
}

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags. always include 'product' default tag for resource-group proper functioning"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

#
# scanning configuration
#

variable "deploy_image_scanning_ecr" {
  type        = bool
  description = "true/false whether to deploy the image scanning on ECR pushed images"
  default     = false
}

variable "deploy_image_scanning_ecs" {
  type        = bool
  description = "true/false whether to deploy the image scanning on ECS running images"
  default     = false
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
