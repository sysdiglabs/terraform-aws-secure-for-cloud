# Example: Single-Account Cloudvision

- A single AWS account usage approach, where resources will report to the account `Cloudtrail`service
- In this account,
    - All the cloudvision service-related resources will be created
    - Cloudwatch `cloud-connect` logs and event-alerts files will be generated

![organizational diagram](./diagram.png)

## Prerequisites

Minimum requirements:

1.  AWS profile credentials configuration of the desired account
1. Secure requirements, as input variable value
    ```
    sysdig_secure_api_token=<SECURE_API_TOKEN>
    ```

See main module [variables.tf](./variables.tf) file for more optional configuration.



## Usage

For quick testing, use this snippet on your terraform files

```terraform
module "aws_cloudvision_organizational" {
  source = "sysdiglabs/cloudvision/aws//examples/single-account"

  sysdig_secure_api_token        = "00000000-1111-2222-3333-444444444444"
}
```

To run this example you need have your [aws master-account `default` profile configured in CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) and to execute:
```terraform
$ terraform init
$ terraform plan
$ terraform apply
```

Note that:
  - This example will create resources that cost money. Run `terraform destroy` when you don't need them anymore
  - for more detailed configuration inspect both main module and example input variables
