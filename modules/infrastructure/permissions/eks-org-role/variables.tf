variable "user_arn" {
  type        = string
  description = "ARN of the IAM user to which roles will be added"
}

variable "cloudtrail_s3_arn" {
  type        = string
  description = "Cloudtrail S3 bucket ARN"
}

#---------------------------------
# optionals - with defaults
#---------------------------------

variable "deploy_threat_detection" {
  type        = bool
  description = "true/false whether to provision cloud_connector permissions"
  default     = true
}

variable "deploy_image_scanning" {
  type        = bool
  description = "true/false whether to provision cloud_scanning permissions"
  default     = true
}


variable "name" {
  type        = string
  default     = "sfc"
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
}

variable "organizational_role_per_account" {
  type        = string
  default     = "OrganizationAccountAccessRole"
  description = "Name of the organizational role deployed by AWS in each account of the organization"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}
