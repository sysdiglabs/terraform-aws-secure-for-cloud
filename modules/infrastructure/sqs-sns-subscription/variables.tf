variable "name" {
  type        = string
  description = "Queue name"
}

variable "cloudtrail_sns_arn" {
  type        = string
  description = "CloudTrail SNS Topic ARN to subscribe the SQS queue"
}

variable "tags" {
  type        = map(string)
  description = "customization of tags to be assigned to all resources. <br/>always include 'product' default tag for resource-group proper functioning.<br/>can also make use of the [provider-level `default-tags`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags)"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}
