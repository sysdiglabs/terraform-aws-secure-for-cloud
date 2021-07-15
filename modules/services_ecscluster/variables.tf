variable "name" {
  type        = string
  description = "Deployment name"
}

variable "tags" {
  type = map(string)
  default = {
    "product" = "cloudvision"
  }
  description = "cloudvision tags"
}
