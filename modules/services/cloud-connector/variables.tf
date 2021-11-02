variable "ecs_cluster" {
  type        = string
  description = "ECS Fargate Cluster where deploy the CloudConnector workload"
}

variable "secure_api_token_secret_name" {
  type        = string
  description = "Sysdig Secure API token SSM parameter name"
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

variable "sns_topic_arn" {
  type        = string
  description = "CloudTrail module created SNS Topic ARN"
}


#---------------------------------
# optionals - with default
#---------------------------------

#
# module composition
#

variable "is_organizational" {
  type        = bool
  default     = false
  description = "whether secure-for-cloud should be deployed in an organizational setup"
}


variable "organizational_config" {
  type = object({
    sysdig_secure_for_cloud_role_arn = string
    connector_ecs_task_role_name     = string
  })
  default = {
    sysdig_secure_for_cloud_role_arn = null
    connector_ecs_task_role_name     = null
  }

  description = <<-EOT
    organizational_config. following attributes must be given
    <ul><li>`sysdig_secure_for_cloud_role_arn` for cloud-connector assumeRole in order to read cloudtrail s3 events</li><li>and the `connector_ecs_task_role_name` which has been granted trusted-relationship over the secure_for_cloud_role</li></ul>
  EOT
}

#
# module config
#

variable "connector_ecs_task_role_name" {
  type        = string
  default     = "ECSTaskRole"
  description = "Default ecs cloudconnector task role name"
}

variable "image" {
  type        = string
  default     = "quay.io/sysdig/cloud-connector:latest"
  description = "Image of the cloud connector to deploy"
}

variable "cloudwatch_log_retention" {
  type        = number
  default     = 5
  description = "Days to keep logs for CloudConnector"
}

variable "verify_ssl" {
  type        = bool
  default     = true
  description = "true/false to determine ssl verification for sysdig_secure_endpoint"
}

variable "extra_env_vars" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables for the Cloud Connector deployment"
}

#
# general
#
variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "name" {
  type        = string
  default     = "sfc-cloudconnector"
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

variable "manage_sns_subscription" {
  type        = bool
  description = "Manage the SNS subscription to the SQS topic"
  default     = true
}
