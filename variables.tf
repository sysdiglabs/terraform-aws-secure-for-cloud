variable "name" {
  type        = string
  description = "Name for the Cloud Vision deployment"
}

variable "cloudbench_deploy" {
  type        = bool
  default     = true
  description = "Deploy the CloudBench module"
}

variable "cloudconnector_deploy" {
  type        = bool
  default     = true
  description = "Deploy the CloudConnector module"
}

variable "ecr_image_scanning_deploy" {
  type        = bool
  default     = true
  description = "Deploy the ECR Scanning module"
}

variable "ecs_image_scanning_deploy" {
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

variable "existing_cloudtrail_sns_topic" {
  type        = string
  default     = ""
  description = "Use an existing CloudTrail SNS Topic"
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
