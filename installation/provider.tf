/*
Two accounts:
  - Root account that deploys the organizational cloudtrail
  - Sandbox account that deploys the cluster and the components and retrieves and scans the logs.
*/

provider "aws" {
  alias = "master"
  profile = "master"
}

provider "aws" {
  alias = "member"
  profile = "member"
}


variable "sysdig_secure_api_token" {
  sensitive = true
  type = string
}

##################
# product aggrupation; rg + tags
##################
variable "cloudvision_product_tags" {
  type = map(string)
  default = {
    "product" = "cloudvision"
  }
}


resource "aws_resourcegroups_group" "rg_cloudvision_master" {
  provider = aws.member
  name = "cloudvision"
  tags = var.cloudvision_product_tags

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "product",
      "Values": ["cloudvision"]
    }
  ]
}
JSON
  }
}

resource "aws_resourcegroups_group" "rg_cloudvision_member" {
  provider = aws.master
  name = "cloudvision"
  tags = var.cloudvision_product_tags

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "product",
      "Values": ["cloudvision"]
    }
  ]
}
JSON
  }
}


##################
# main modules
##################

module "cloudvision-organizational-cloudtrail" {
  source = "./../modules/organizational/cloudtrail"
  providers = {
    aws = aws.master
  }

  cloudtrail_name = "cloudtrail-org"
  s3_bucket_name  = "cloudtrail-org"
  cloudvision_product_tags = aws_resourcegroups_group.rg_cloudvision_master.tags
}



module "cloudvision-deployments-cluster" {
  source = "./../modules/organizational/cloud_services"
  providers = {
    aws = aws.member
  }

  cloudtrail_sns_topic_arn = module.cloudvision-organizational-cloudtrail.sns_topic_arn
  sysdig_secure_api_token = var.sysdig_secure_api_token
  cloudvision_product_tags = aws_resourcegroups_group.rg_cloudvision_member.tags
}