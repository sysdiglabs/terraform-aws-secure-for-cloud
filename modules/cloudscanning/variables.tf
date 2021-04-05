variable "name" {
  type        = string
  default     = "cloud-scanning"
  description = "Name for the Cloud Scanning deployment"
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
  description = "Extra environment variables for the Cloud Scanning deployment"
}

variable "verify_ssl" {
  type        = bool
  default     = true
  description = "Whether to verify the SSL certificate of the endpoint or not"
}

variable "image" {
  type        = string
  default     = "sysdiglabs/cloud-scanning:latest"
  description = "Image of the cloud scanning to deploy"
}

variable "sns_topic_arns" {
  type        = list(string)
  description = "ARNs of the SNS Topics to subscribe"
}

variable "deploy_ecr" {
  type        = bool
  description = "Enable ECR integration"
}

variable "deploy_ecs" {
  type        = bool
  description = "Enable ECS integration"
}

variable "codebuild_project" {
  type        = string
  description = "CodeBuild project that executes the inline-scan"
}
