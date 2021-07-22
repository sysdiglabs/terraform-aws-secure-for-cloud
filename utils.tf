#---------------------------------------------------------------
# organizational account sysdig-cloudvision resource-group
#---------------------------------------------------------------
resource "aws_resourcegroups_group" "sysdig-cloudvision" {
  name = "sysdig-cloudvision"
  tags = var.tags

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "product",
      "Values": ["sysdig-cloudvision"]
    }
  ]
}
JSON
  }
}

#-------------------------------------
# (optional) cloudvision-account creation
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account
#-------------------------------------
resource "aws_organizations_account" "cloudvision" {
  count = var.org_cloudvision_account_creation_email != "" ? 1 : 0
  name  = "cloudvision"
  email = var.org_cloudvision_account_creation_email
  tags  = var.tags
}
