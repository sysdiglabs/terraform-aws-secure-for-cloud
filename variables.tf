variable "name" {
  type        = string
  description = "Name for the Cloud Vision deployment"
}

variable "deploy_cloudbench" {
  type        = bool
  default     = true
  description = "Deploy the CloudBench module"
}

variable "deploy_cloudconnector" {
  type        = bool
  default     = true
  description = "Deploy the CloudConnector module"
}

variable "deploy_ecr_scanning" {
  type        = bool
  default     = true
  description = "Deploy the ECR Scanning module"
}

variable "deploy_ecs_scanning" {
  type        = bool
  default     = true
  description = "Deploy the ECS Scanning module"
}

variable "existing_ecs_cluster" {
  type        = string
  default     = ""
  description = "Use an existing ECS cluster"
}

variable "existing_ecs_cluster_vpc" {
  type        = string
  default     = ""
  description = "Use an existing ECS cluster VPC"
}

variable "existing_ecs_cluster_private_subnets" {
  type        = list(string)
  default     = []
  description = "Use the existing ECS cluster private subnets"
}

variable "cloud_trail_sns_topics" {
  type        = list(string)
  description = "CloudTrail SNS Topics"
}

variable "sysdig_secure_api_token" {
  type        = string
  sensitive   = true
  description = "Sysdig Secure API token"
}

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}
