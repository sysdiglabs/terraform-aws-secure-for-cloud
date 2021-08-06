resource "aws_resourcegroups_group" "sysdig_cloudvision" {
  count = var.create ? 1 : 0

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
