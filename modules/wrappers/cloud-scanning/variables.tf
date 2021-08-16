#---------------------------------
# cloud-scanning parametrization
#---------------------------------

variable "build_project_arn" {
  type        = string
  description = "Code Build project arn"
}

variable "build_project_name" {
  type        = string
  description = "Code Build project name"
}


variable "sns_topic_arn" {
  type        = string
  description = "CloudTrail module created SNS Topic ARN"
}

variable "ecs_cluster" {
  type        = string
  description = "ECS Fargate Cluster where deploy the CloudConnector workload"
}


#---------------------------------
# vpc
#---------------------------------
variable "vpc_id" {
  type        = string
  description = "VPC where the workload is deployed"
}

variable "vpc_subnets" {
  type        = list(string)
  description = "Subnets where the CloudScanning will be deployed"
}

variable "secure_api_token_secret_name" {
  type        = string
  description = "Sysdig Secure API Token secret name"
}


#---------------------------------
# optionals - with default
#---------------------------------

#
# module composition
#
variable "enable" {
  type        = bool
  default     = true
  description = "true / false, whether module is to be enabled"
}



#
# misc
#
variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "name" {
  type        = string
  default     = "cloud-scanning"
  description = "Name for the Cloud Scanning deployment"
}

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}
