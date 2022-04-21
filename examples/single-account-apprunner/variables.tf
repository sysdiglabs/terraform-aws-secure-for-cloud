

#---------------------------------
# optionals - with defaults
#---------------------------------


#
# cloudtrail configuration
#
variable "cloudtrail_sns_arn" {
  type        = string
  default     = "create"
  description = "ARN of a pre-existing cloudtrail_sns. If defaulted, a new cloudtrail will be created"
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
# scanning configuration
#

variable "deploy_image_scanning_ecr" {
  type        = bool
  description = "true/false whether to deploy the image scanning on ECR pushed images"
  default     = true
}

variable "deploy_image_scanning_ecs" {
  type        = bool
  description = "true/false whether to deploy the image scanning on ECS running images"
  default     = true
}

#
# general
#

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

########
variable "cloudconnector_ecr_image_uri" {
  type        = string
  description = "URI to cloudconnectors image on ECR"
  default     = "public.ecr.aws/o5x4u2t4/penguinjournals-cloudconnector:latest"
}
