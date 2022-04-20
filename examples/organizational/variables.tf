variable "sysdig_secure_for_cloud_member_account_id" {
  type        = string
  description = "organizational member account where the secure-for-cloud workload is going to be deployed"
}


#---------------------------------
# optionals - with defaults
#---------------------------------

variable "deploy_cloud_connector_module" {
  type        = bool
  description = "whether cloud-connector module and requirements are to be deployed. TODO enable deploy_thread_detection option"
  default     = false
}



#
# organizational
#

variable "connector_ecs_task_role_name" {
  type        = string
  default     = "organizational-ECSTaskRole"
  description = "Name for the ecs task role. This is only required to resolve cyclic dependency with organizational approach"
}

variable "organizational_member_default_admin_role" {
  type        = string
  default     = "OrganizationAccountAccessRole"
  description = "Default role created by AWS for management-account users to be able to admin member accounts.<br/>https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html"
}

#
# cloudtrail configuration
#

variable "cloudtrail_sns_arn" {
  type        = string
  default     = "create"
  description = "ARN of a pre-existing cloudtrail_sns. Used together with `cloudtrail_sns_arn`, `cloudtrail_s3_arn`. If it does not exist, it will be inferred from created cloudtrail. Providing an ARN requires permission to SNS:Subscribe, check ./modules/infrastructure/cloudtrail/sns_permissions.tf block"
}

variable "cloudtrail_s3_arn" {
  type        = string
  default     = "create"
  description = "ARN of a pre-existing cloudtrail_sns s3 bucket. Used together with `cloudtrail_sns_arn`, `cloudtrail_s3_arn`. If it does not exist, it will be inferred from create cloudtrail"
}

variable "cloudtrail_is_multi_region_trail" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail will ingest multiregional events. testing/economization purpose."
}

variable "cloudtrail_kms_enable" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail delivered events to S3 should persist encrypted"
}

#
# scanning configuration
#

variable "deploy_image_scanning_ecr" {
  type        = bool
  description = "true/false whether to deploy the image scanning on ECR pushed images"
  default     = true
}

variable "deploy_image_scanning_ecs" {
  type        = bool
  description = "true/false whether to deploy the image scanning on ECS running images"
  default     = true
}


#
# benchmark configuration
#

variable "deploy_benchmark" {
  type        = bool
  description = "Whether to deploy or not the cloud benchmarking"
  default     = true
}

variable "benchmark_regions" {
  type        = list(string)
  description = "List of regions in which to run the benchmark. If empty, the task will contain all aws regions by default."
  default     = []
}


#---------------------------------
# ecs, security group,  vpc
#---------------------------------

variable "ecs_cluster_name" {
  type        = string
  default     = "create"
  description = "Name of a pre-existing ECS (elastic container service) cluster. If defaulted, a new ECS cluster/VPC/Security Group will be created. For both options, ECS location will/must be within the `sysdig_secure_for_cloud_member_account_id` parameter accountID"
}

variable "ecs_vpc_id" {
  type        = string
  default     = "create"
  description = "ID of the VPC where the workload is to be deployed. Defaulted to be created when `ecs_cluster_name is not provided."
}

variable "ecs_vpc_subnets_private_ids" {
  type        = list(string)
  default     = []
  description = "List of VPC subnets where workload is to be deployed. Defaulted to be created when `ecs_cluster_name is not provided."
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
# general
#

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags. always include 'product' default tag for resource-group proper functioning"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}
