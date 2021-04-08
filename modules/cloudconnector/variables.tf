variable "name" {
  type        = string
  default     = "cloud-connector"
  description = "Name for the Cloud Connector deployment"
}

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

variable "config_bucket" {
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
  default     = "sysdiglabs/cloud-connector:latest"
  description = "Image of the cloud connector to deploy"
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of the SNS Topic to subscribe"
}
