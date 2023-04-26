#---------------------------------
# optionals - with defaults
#---------------------------------


#
# cloudtrail configuration
#
variable "cloudtrail_sns_arn" {
  type        = string
  default     = "create"
  description = "ARN of a pre-existing cloudtrail_sns. If defaulted, a new cloudtrail will be created. If specified, sysdig deployment account and region must match with the specified SNS"
}

variable "cloudtrail_is_multi_region_trail" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail will ingest multiregional events"
}

variable "cloudtrail_kms_enable" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail delivered events to S3 should persist encrypted"
}

variable "cloudtrail_s3_bucket_expiration_days" {
  type        = number
  default     = 5
  description = "Number of days that the logs will persist in the bucket"
}

#
# ecs, security group,  vpc
#

variable "ecs_cluster_name" {
  type        = string
  default     = "create"
  description = "Name of a pre-existing ECS (elastic container service) cluster. If defaulted, a new ECS cluster/VPC/Security Group will be created. If specified all three parameters `ecs_cluster_name`, `ecs_vpc_id` and `ecs_vpc_subnets_private_ids` are required."
}

variable "ecs_vpc_id" {
  type        = string
  default     = "create"
  description = "ID of the VPC where the workload is to be deployed. If defaulted a new VPC will be created. If specified all three parameters `ecs_cluster_name`, `ecs_vpc_id` and `ecs_vpc_subnets_private_ids` are required"
}

variable "ecs_vpc_subnets_private_ids" {
  type        = list(string)
  default     = []
  description = "List of VPC subnets where workload is to be deployed. If defaulted new subnets will be created within the VPC. A minimum of two subnets is suggested. If specified all three parameters `ecs_cluster_name`, `ecs_vpc_id` and `ecs_vpc_subnets_private_ids` are required."
}

variable "ecs_vpc_region_azs" {
  type        = list(string)
  description = "List of Availability Zones for ECS VPC creation. e.g.: [\"apne1-az1\", \"apne1-az2\"]. If defaulted, two of the default 'aws_availability_zones' datasource will be taken"
  default     = []
}

# Configure CPU and memory in pairs.
# See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
variable "ecs_task_cpu" {
  type        = string
  description = "Amount of CPU (in CPU units) to reserve for cloud-connector task"
  default     = "256"
}

variable "ecs_task_memory" {
  type        = string
  description = "Amount of memory (in megabytes) to reserve for cloud-connector task"
  default     = "512"
}

#
# scanning configuration
#

variable "deploy_beta_image_scanning_ecr" {
  type        = bool
  description = "true/false whether to deploy the beta image scanning on ECR pushed images (experimental and unsupported)"
  default     = false
}

variable "deploy_image_scanning_ecr" {
  type        = bool
  description = "true/false whether to deploy the image scanning on ECR pushed images"
  default     = false
}

variable "deploy_image_scanning_ecs" {
  type        = bool
  description = "true/false whether to deploy the image scanning on ECS running images"
  default     = false
}


#
# benchmark configuration
#

variable "deploy_benchmark" {
  type        = bool
  description = "Whether to deploy or not the cloud benchmarking"
  default     = true
}

#
# cloud connector connector configuration
#
variable "cloud_connector_image" {
  type        = string
  description = "Image to use for the cloud connector. If empty, the default image will be used."
  default     = "quay.io/sysdig/cloud-connector:latest"
}

#
# general
#

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}

variable "tags" {
  type        = map(string)
  description = "customization of tags to be assigned to all resources. <br/>always include 'product' default tag for resource-group proper functioning.<br/>can also make use of the [provider-level `default-tags`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags)"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

#
# Autoscaling configurations
#
variable "enable_autoscaling" {
  type        = bool
  description = "Whether to enable autoscaling or not"
  default     = false
}

variable "autoscaling_config" {
  type = object({
    min_replicas        = number
    max_replicas        = number
    upscale_threshold   = number
    downscale_threshold = number
  })

  default = {
    min_replicas        = 1
    max_replicas        = 10
    upscale_threshold   = 60
    downscale_threshold = 30
  }
  description = "if enable_autoscaliing is enabled, ECS autoscaling configuration. for more insight check source code"
}
