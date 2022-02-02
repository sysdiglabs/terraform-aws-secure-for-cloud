variable "secure_api_token_secret_name" {
  type        = string
  description = "Sysdig Secure API token SSM parameter name"
}

variable "build_project_arn" {
  type        = string
  description = "Code Build project arn"
}

variable "build_project_name" {
  type        = string
  description = "Code Build project name"
}


#---------------------------------
# ecs, security group,  vpc
# TODO. convert into an object?
#---------------------------------

variable "ecs_cluster_name" {
  type        = string
  default     = "create"
  description = "Name of a pre-existing ECS (elastic container service) cluster. If defaulted, a new ECS cluster/VPC/Security Group will be created"
}

variable "ecs_vpc_subnets_private" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "List of VPC subnets where workload is to be deployed. Defaulted to be created when 'ecs_cluster_name' is not provided."
}

variable "ecs_sg_id" {
  type        = string
  default     = "create"
  description = "ID of the Security Group where the workload is to be deployed. Defaulted to be created when 'ecs_cluster_name' is not provided"
}




#---------------------------------
# cloud-connector parametrization
#---------------------------------

variable "sns_topic_arn" {
  type        = string
  description = "ARN of a cloudtrail-sns topic"
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
    organizational_role_per_account  = string
    connector_ecs_task_role_name     = string
  })
  default = {
    sysdig_secure_for_cloud_role_arn = null
    organizational_role_per_account  = null
    connector_ecs_task_role_name     = null
  }

  description = <<-EOT
    organizational_config. following attributes must be given
    <ul>
      <li>`sysdig_secure_for_cloud_role_arn` for cloud-connector assumeRole in order to read cloudtrail s3 events</li>
      <li>`connector_ecs_task_role_name` which has been granted trusted-relationship over the secure_for_cloud_role</li>
      <li>`organizational_role_per_account` is the name of the organizational role deployed by AWS in each account of the organization</li>
    </ul>
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
