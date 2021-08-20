resource "aws_resourcegroups_group" "sysdig_secure_for_cloud" {

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
      "Values": ["sysdig-secure-for-cloud"]
    }
  ]
}
JSON
  }
}
