# Example: Organizational Cloudvision

- AWS Organization usage approach, where all the member accounts will report to a single `Organizational Cloudtrail`
- When an account becomes part of an organization, AWS will create an `OrganizationAccountAccessRole` [for account management](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html), which cloudvision module will use for member-account provisioning
- In the Cloudvision member account
    - An additional role `SysdigCloudvisionRole` will be created within the master account, to be able to read s3 bucket events
    - All the cloudvision service-related resources will be created
    - Cloudwatch `cloud-connect` logs and event-alerts files will be generated

![organizational diagram](./diagram-org.png)

## Prerequisites

Minimum requirements:

1.  Have an existing AWS account as the organization master account
    - organzational cloudTrail service must be enabled
1.  AWS profile credentials configuration of the `master` account of the organization
    - this account credentials must be [able to manage cloudtrail creation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/creating-trail-organization.html)
      > You must be logged in with the management account for the organization to create an organization trail. You must also have sufficient permissions for the IAM user or role in the management account to successfully create an organization trail.
    - cloudvision organizational member account id, as input variable value
        ```
       cloudvision_member_account_id=<ORGANIZATIONAL_CLOUDVISION_ACCOUNT_ID>
        ```
1. Secure requirements, as input variable value
    ```
    sysdig_secure_api_token=<SECURE_API_TOKEN>
    ```

See main module [variables.tf](./variables.tf) file for more optional configuration.



## Usage

For quick testing, use this snippet on your terraform files

```terraform
module "aws_cloudvision_organizational" {
  source = "sysdiglabs/cloudvision/aws//examples/organizational"

  sysdig_secure_api_token        = "00000000-1111-2222-3333-444444444444"
  cloudvision_member_account_id  = "<ORG_MEMBER_ACCOUNT_FOR_CLOUDVISION>"
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
  - For more detailed configuration inspect both main module and example input variables
