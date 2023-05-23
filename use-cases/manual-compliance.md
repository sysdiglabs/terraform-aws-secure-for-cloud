# Manually Onboard an AWS Account for CSPM

To enable CSPM (Compliance) in your AWS account, you create the following resources on the Sysdig Secure SaaS backend:

    - An `account` representing the AWS account for which you want to enable CSPM
    - A trust-relationship `component` that represents the IAM Role in your AWS account
    - A CSPM `feature` that indicates CSPM scans should be run against this account
 

## Guidelines

- This method of installation will only support CSPM (Compliance).

- The following features will not work:

    - Threat Detection
    - Identity and Access
    - Image Scanning

  To install other features, see the [Installation Guide](https://docs.sysdig.com/en/docs/installation/sysdig-secure/connect-cloud-accounts/aws/).

- In each AWS account you want to run CSPM, you must create an IAM Role with `SecurityAudit` permissions that Sysdig is able to assume.

- Ensure that you make Sysdig aware of these accounts and roles.


## Preparation

To learn more about using the Sysdig Secure APIs, see [Development Tools](https://docs.sysdig.com/en/docs/developer-tools/).

### Retrieve the **Sysdig Trusted Identity** and **ExternalID**

Run the following to retrieve the `TrustRelationshipPolicy`:

```shell
$ curl -s 'https://<SYSDIG_SECURE_ENDPOINT>/api/cloud/v2/aws/trustedRoleDoc' \
--header 'Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>'
```
This policy will be used when you create an IAM role as given below.

An example response to this call:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::761931097553:role/us-east-1-production-secure-assume-role"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "8000e8d3b0f082c3f9a33e6ae6e39774"
        }
      }
    }
  ]
}
```

## Provision Your AWS Account

### Create an IAM Role

Sysdig secures your cloud environment by assuming an IAM Role you create within your AWS Account.

1. Create a new IAM Role with a Custom trust policy.
2. Set the value of the trust polity to the `TrustRelationshipPolicy` policy retrieved above.
3. Attach the AWS-managed `arn:aws:iam::aws:policy/SecurityAudit` policy.
4. Give the role a unique name, and save the name for later use.
5. Add **Tags** and a **Description** as desired.

For more information, see [IAM Roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create.html)

## Provision Sysdig

### Create an AWS Account Representation

```shell
$ curl "https://<SYSDIG_SECURE_ENDPOINT>/api/cloudauth/v1/accounts" \
--header "Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>" \
-X POST \
-H 'Accept: application/json' \
-H 'Content-Type: application/json' \
-d '{
  "providerId": "<AWS_ACCOUNT_ID>",
  "provider": "PROVIDER_AWS",
  "enabled": true
}'
```

An example response to this call:

```json
{
  "id": "2fb94253-3a93-4d43-a739-2cb8c1c6f886",
  "customerId": "123",
  "enabled": true,
  "providerId": "123456789012",
  "provider": "PROVIDER_AWS",
  "feature": {},
  "createdAt": "2023-05-22T21:26:03.288075Z",
  "updatedAt": "2023-05-22T21:26:03.288358Z"
}
```

Take note of the `id` field, which is referenced in subsequent calls. Note this is **not the AWS AccountID**, which is stored in the `providerId` field.


### Create a Trust Relationship Component

1. Collect the following:

  - `<CLOUD_ACCOUNT_ID>`: The `id` field retrieved from the response in the previous step.
  - `<ROLE_NAME>`: The name of the IAM role created above. Note this is not the ARN, but the role name.

2. Replace `<CLOUD_ACCOUNT_ID>` and `<ROLE_NAME>` with the `id` and the role name respectively, and run the following:

      ```shell
      $ curl -s "https://<SYSDIG_SECURE_ENDPOINT>/api/cloudauth/v1/accounts/<CLOUD_ACCOUNT_ID>/components" \
      --header "Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>" \
      -X POST \
      -H 'Accept: application/json' \
      -H 'Content-Type: application/json' \
      -d '{
        "type": "COMPONENT_TRUSTED_ROLE",
        "instance": "manual",
        "trustedRoleMetadata": {
          "aws": {
            "roleName": "<ROLE_NAME>"
          }
        }
      }'
      ```


### Create a CSPM Feature Representation

Replace `<CLOUD_ACCOUNT_ID>` with the `id` field you have retrieved before and run the following:

```shell
$ curl -s "https://<SYSDIG_SECURE_ENDPOINT>/api/cloudauth/v1/accounts/<CLOUD_ACCOUNT_ID>/feature/FEATURE_SECURE_CONFIG_POSTURE" \
--header "Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>" \
-X PUT \
-H 'Accept: application/json' \
-H 'Content-Type: application/json' \
-d '{
  "type": "FEATURE_SECURE_CONFIG_POSTURE",
  "enabled": true,
  "components": ["COMPONENT_TRUSTED_ROLE/manual"]
}'
```

## Verify the Installation

Verify that your installation is successful by following the [CSPM Validation instructions](https://docs.sysdig.com/en/docs/installation/sysdig-secure/connect-cloud-accounts/aws/#check-cspm).
