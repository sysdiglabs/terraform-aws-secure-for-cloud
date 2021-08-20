variable "account_id" {
  type = string
  description = "the account_id in which to provision the cloud-bench IAM role"
}

#---------------------------------
# optionals - with default
#---------------------------------

variable "regions" {
  type = list(string)
  default = [
    "af-south-1",
    "eu-north-1",
    "ap-south-1",
    "eu-west-3",
    "eu-west-2",
    "eu-south-1",
    "eu-west-1",
    "ap-northeast-3",
    "ap-northeast-2",
    "me-south-1",
    "ap-northeast-1",
    "sa-east-1",
    "ca-central-1",
    "ap-east-1",
    "ap-southeast-1",
    "ap-southeast-2",
    "eu-central-1",
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
  ]
  description = "List of regions in which to run the benchmark"
}

variable "tags" {
  type = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

  "af-south-1",<br>  "eu-north-1",<br>  "ap-south-1",<br>  "eu-west-3",<br>  "eu-west-2",<br>  "eu-south-1",<br>  "eu-west-1",<br>  "ap-northeast-3",<br>  "ap-northeast-2",<br>  "me-south-1",<br>  "ap-northeast-1",<br>  "sa-east-1",<br>  "ca-central-1",<br>  "ap-east-1",<br>  "ap-southeast-1",<br>  "ap-southeast-2",<br>  "eu-central-1",<br>  "us-east-1",<br>  "us-east-2",<br>  "us-west-1",<br>  "us-west-2",<br>
