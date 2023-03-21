#---------------------------------
# optionals - with defaults
#---------------------------------

#
# cloudtrail configuration
#

variable "cloudtrail_sns_arn" {
  type        = string
  default     = "create"
  description = "ARN of a pre-existing cloudtrail_sns. If defaulted, a new cloudtrail will be created. If specified, deployment region must match Cloudtrail S3 bucket region"
}

variable "cloudtrail_is_multi_region_trail" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail will ingest multiregional events. testing/economization purpose. "
}

variable "cloudtrail_kms_enable" {
  type        = bool
  default     = true
  description = "true/false whether s3 should be encrypted. testing/economization purpose."
}

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
# aws iam user configuration
#
variable "deploy_aws_iam_user" {
  type        = bool
  description = "true/false whether to deploy an iam user. if set to false, check [required role permissions](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/resources/policy-single-account-k8s-aws.json)"
  default     = true
}
