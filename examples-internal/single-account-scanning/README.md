## Usage

```terraform
module "cloudvision_aws_single_account" {
  source = "github.com/sysdiglabs/terraform-aws-cloudvision//examples-internal/single-account-scanning"
  sysdig_secure_api_token = "00000000-1111-2222-3333-444444444444"
}
```

see [`variables.tf`](./variables.tf) for more options
