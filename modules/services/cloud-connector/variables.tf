variable "ecs_cluster" {
  type        = string
  description = "ECS Fargate Cluster where deploy the CloudConnector workload"
}

variable "organizational_setup" {
  type = object({
    is_organizational        = bool
    services_assume_role_arn = string
  })
  default = {
    is_organizational        = false
    services_assume_role_arn = null
  }
  description = "whether organizational setup is to be enabled. if true, services_assume_role_arn, for cloud_connect to assumeRole and read events on master account"
  validation {
    condition     = var.organizational_setup.is_organizational == false || (var.organizational_setup.is_organizational == true && can(tostring(var.organizational_setup.services_assume_role_arn)))
    error_message = "If is_organizational=true, services_assume_role_arn must not be null."
  }
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
  description = "Subnets where the CloudConnector will be deployed"
}


#---------------------------------
# cloud-connector parametrization
#---------------------------------

variable "sysdig_secure_api_token" {
  type        = string
  sensitive   = true
  description = "Sysdig Secure API token"
}

variable "sns_topic_arn" {
  type        = string
  description = "CloudTrail module created SNS Topic ARN"
}


#---------------------------------
# optionals - with default
#---------------------------------

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "name" {
  type        = string
  default     = "cloud-connector"
  description = "Name for the Cloud Connector deployment"
}

variable "image" {
  type        = string
  default     = "sysdiglabs/cloud-connector:latest"
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
