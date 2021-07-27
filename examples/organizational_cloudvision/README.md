# UseCase: Organizational Cloudvision

- AWS Organization usage approach, where all the member accounts will report to a single `Organizational Cloudtrail`
- When an account becomes part of an organization, AWS will create an `OrganizationAccountAccessRole` [for account management](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html), which cloudvision module will use for member-account provisioning 
- Cloudvision member account will be created, where all the cloudvision service-related resources will be created
- An additional role `SysdigCloudvisionRole` will be created within the master account, to be able to read s3 bucket events

![organizational diagram](./diagram.png)

## Prerequisites

Minimum requirements:

1.  Have an existing AWS account as the organization master account
    - organzational cloudTrail service must be enabled
1.  AWS profile credentials configuration of the `master` account of the organization
    - this account credentials must be [able to manage cloudtrail creation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/creating-trail-organization.html)
      > You must be logged in with the management account for the organization to create an organization trail. You must also have sufficient permissions for the IAM user or role in the management account to successfully create an organization trail.
    - credentials will be picked from `default` aws profile, but can be changed vía [vars.terraform\_connection\_profile](#input\_terraform\_connection\_profile)
    - cloudvision organizational member account id, as input variable value
        ```
       org_cloudvision_account_id=<ORGANIZATIONAL_CLOUDVISION_ACCOUNT_ID>
        ```
1. Secure requirements, as input variable value
    ```
    sysdig_secure_api_token=<SECURE_API_TOKEN>
    ```

See main module [variables.tf](./variables.tf) file for more optional configuration.



## Usage

Insert this snippet on your terraform files to access `sysdiglabs/cloudvision/aws` provider

```terraform
module "cloudvision_aws" {
  source = "sysdiglabs/cloudvision/aws"

  sysdig_secure_api_token        = "00000000-1111-2222-3333-444444444444"
  org_cloudvision_account_id     = "<ORG_MEMBER_ACCOUNT_FOR_CLOUDVISION>"
  org_cloudvision_account_region = "<REGION_CLOUDVISION_RESOURCES; eg: eu-central-1>"
}
```

To run this example you need to execute:
```terraform
$ terraform init
$ terraform plan
$ terraform apply
```
Note that this example may create resources which can cost money (AWS Elastic IP, for example). 
Run `terraform destroy` when you don't need these resources