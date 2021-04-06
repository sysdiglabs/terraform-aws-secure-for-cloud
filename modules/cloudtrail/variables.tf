variable "name" {
  type        = string
  description = "Deployment name"
}

variable "bucket_name" {
  type        = string
  description = "Bucket name that will be created with the cloud trail resources, where the logs will be saved."
}

variable "main_account_id" {
  type        = string
  description = "ID of the main account that can be subscribed to the SNS created"
}

variable "bucket_expiration_days" {
  type        = number
  default     = 5
  description = "Number of days that the logs will persist in the bucket"
}
