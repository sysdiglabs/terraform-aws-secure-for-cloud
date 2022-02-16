variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}

variable "cloudtrail_s3_sns_sqs_url" {
  type        = string
  description = "Organization cloudtrail event notification  S3-SNS-SQS URL to listen to"
}

# cloud-connector deployment params
variable "aws_access_key_id" {
  sensitive   = true
  type        = string
  description = "cloud-connector. aws credentials in order to access required aws resources. aws.accessKeyId"
}

variable "aws_secret_access_key" {
  sensitive   = true
  type        = string
  description = "cloud-connector. aws credentials in order to access required aws resources. aws.secretAccessKey"
}


#---------------------------------
# optionals - with defaults
#---------------------------------


#
# general
#
variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}

variable "sysdig_secure_url" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}
