variable "name" {
  type        = string
  description = "Queue name"
}

variable "sns_topic_arn" {
  type        = string
  description = "CloudTrail SNS Topic ARN to subscribe the SQS queue"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

variable "manage_sns_subscription" {
  type        = bool
  default     = true
  description = "Create SNS subscription to feed into SQS topic"
}

