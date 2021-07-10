variable "name" {
  type        = string
  description = "Deployment name"
}

variable "cloudvision_product_tags"{
  type=map(string)
  default = {
    "product" = "cloudvision"
  }
}