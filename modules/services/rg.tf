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
