############################
##  required
############################
variable "cloudtrail_name" {
  type        = string
  description = "CloudTrail name"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name that will be created with the CloudTrail resources, where the logs will be saved."
}



############################
# optionals - with default
############################
variable "s3_bucket_expiration_days" {
  type        = number
  default     = 5
  description = "Number of days that the logs will persist in the bucket"
}

variable "cloudvision_product_tags" {
  type = map(string)
  default = {
    "product" = "cloudvision"
  }
}
