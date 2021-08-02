resource "aws_resourcegroups_group" "sysdig_cloudvision" {
  name = var.name
  tags = var.tags

  # FIXME. convert tags to JSON resource_query
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
