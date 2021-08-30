#---------------------------------
# cloud-scanning specific
#---------------------------------
variable "secure_api_token_secret_name" {
  type        = string
  description = "Sysdig Secure API Token secret name"
}

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


#---------------------------------
# optionals - with default
#---------------------------------

#
# cloud-scanning specific
#

variable "image" {
  type        = string
  default     = "quay.io/sysdig/cloud-scanning:latest"
  description = "Image of the cloud scanning to deploy"
}

variable "scanning_ecs_task_role_name" {
  type        = string
  default     = "scanning-ECSTaskRole"
  description = "Default ecs cloudscanning task role name"
}

variable "cloudwatch_log_retention" {
  type        = number
  default     = 5
  description = "Days to keep logs for CloudScanning"
}

variable "verify_ssl" {
  type        = bool
  default     = true
  description = "true/false to determine ssl secure connection verification"
}

variable "extra_env_vars" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables for the Cloud Scanning deployment"
}

variable "is_organizational" {
  type        = bool
  default     = false
  description = "whether secure-for-cloud should be deployed in an organizational setup"
}

variable "organizational_config" {
  type = object({
    sysdig_secure_for_cloud_role_arn = string
    organizational_role_per_account  = string
    scanning_ecs_task_role_name      = string
  })
  default = {
    sysdig_secure_for_cloud_role_arn = ""
    organizational_role_per_account  = ""
    scanning_ecs_task_role_name      = ""
  }

  description = <<-EOT
    organizational_config. following attributes must be given
    <ul>
        <li>`sysdig_secure_for_cloud_role_arn` for cloud-connector assumeRole in order to read cloudtrail s3 events</li>
        <li>`scanning_ecs_task_role_name` which has been granted trusted-relationship over the secure_for_cloud_role</li>
        <li>`organizational_role_per_account` is the name of the organizational role deployed by AWS in each account of the organization</li>
    </ul>
  EOT
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
  default     = "sysdig-secure-for-cloudscanning"
  description = "Name for the Cloud Scanning deployment"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}
