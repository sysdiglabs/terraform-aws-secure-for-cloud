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

