variable "ecs_cluster" {
  type        = string
  description = "ECS Fargate Cluster where deploy the CloudConnector workload"
}

variable "config_bucket" {
  type        = string
  description = "Name of a bucket (must exist) where the configuration YAML files will be stored"
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of the SNS Topic to subscribe"
}

variable "services_assume_role_arn" {
  type        = string
  description = "Cloudvision service required assumeRole arn"
}

#---------------------------------
# vpc
#---------------------------------
variable "vpc" {
  type        = string
  description = "VPC where the workload is deployed"
}

variable "subnets" {
  type        = list(string)
  description = "Subnets where the CloudConnector will be deployed"
}


#---------------------------------
# cloud-connect parametrization
#---------------------------------

variable "ssm_endpoint" {
  type        = string
  description = "Name of the parameter in SSM containing the Sysdig Secure Endpoint URL"
}

variable "ssm_token" {
  type        = string
  description = "Name of the parameter in SSM containing the Sysdig Secure API Token"
}


#---------------------------------
# optionals - with default
#---------------------------------

variable "name" {
  type        = string
  default     = "cloud-connector"
  description = "Name for the Cloud Connector deployment"
}

variable "image" {
  type        = string
  default     = "sysdiglabs/cloud-connector:master"
  description = "Image of the cloud connector to deploy"
}

variable "cloudwatch_log_retention" {
  type        = number
  default     = 5
  description = "Days to keep logs for CloudConnector"
}

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}

variable "verify_ssl" {
  type        = bool
  default     = true
  description = "true/false to determine ssl verification"
}

variable "extra_env_vars" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables for the Cloud Connector deployment"
}
