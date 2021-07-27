#---------------------------------------------------------------
# organizational account sysdig-cloudvision resource-group
#---------------------------------------------------------------
resource "aws_resourcegroups_group" "sysdig_cloudvision" {
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
