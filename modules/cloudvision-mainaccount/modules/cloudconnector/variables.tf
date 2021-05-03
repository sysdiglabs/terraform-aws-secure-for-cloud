variable "log_retention" {
  type        = number
  default     = 5
  description = "Days to keep logs for CloudConnector"
}

variable "vpc" {
  type        = string
  description = "VPC where the workload is deployed"
}

variable "subnets" {
  type        = list(string)
  description = "Subnets where the CloudConnector will be deployed"
}

variable "ecs_cluster" {
  type        = string
  description = "ECS Fargate Cluster where deploy the CloudConnector workload"
}

variable "ssm_endpoint" {
  type        = string
  description = "Name of the parameter in SSM containing the Sysdig Secure Endpoint URL"
}

variable "ssm_token" {
  type        = string
  description = "Name of the parameter in SSM containing the Sysdig Secure API Token"
}

variable "extra_env_vars" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables for the Cloud Connector deployment"
}

variable "s3_config_bucket" {
  type        = string
  description = "Name of a bucket (must exist) where the configuration YAML files will be stored"
}

variable "verify_ssl" {
  type        = bool
  default     = true
  description = "Whether to verify the SSL certificate of the endpoint or not"
}

variable "config_content" {
  type        = string
  description = "Configuration contents for the file stored in the S3 bucket"
  default     = null
}

variable "config_source" {
  type        = string
  description = "Configuration source file for the file stored in the S3 bucket"
  default     = null
}

variable "image" {
  type        = string
  default     = "sysdiglabs/cloud-connector:airadier-test"
  description = "Image of the cloud connector to deploy"
}

variable "naming_prefix" {
  type        = string
  default     = "SysdigCloud"
  description = "Prefix for resource names. Use the default unless you need to install multiple instances, and modify the deployment at the main account accordingly"

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]+$", var.naming_prefix)) && length(var.naming_prefix) > 1 && length(var.naming_prefix) <= 64
    error_message = "Must enter a naming prefix up to 64 alphanumeric characters."
  }
}

variable "accounts_and_regions" {
  type = list(object({
    account_id = string
    region     = string
  }))
  default     = []
  description = "A list of child AWS accounts and regions where CloudTrail is enabled."
}
