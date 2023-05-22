# Manually onboard an AWS account for CSPM

Please note: This method of installation will **only** support CSPM (Compliance). 
The following features **will not work**: Threat Detection, Identity and Access, Image Scanning. 
To install other features, please follow our full [Installation Guide](https://docs.sysdig.com/en/docs/installation/sysdig-secure/connect-cloud-accounts/aws/)

In each AWS account where you would like to run CSPM, we must create an IAM Role with `SecurityAudit` permissions that Sysdig is able to assume.

In addition, we must make Sysdig aware of these accounts and roles.
These instructions will guide you to create the following resources on the Sysdig Secure SaaS backend:
- An `account` representing the AWS account in which you would like to enable CSPM,
- A trust-relationship `component` that represents the IAM Role in your AWS account,
- A CSPM `feature` that indicates CSPM scans should be run against this account.

## Preparation

To learn more about how to use Sysdig Secure APIs, please see: [How to use development tools](https://docs.sysdig.com/en/docs/developer-tools/).

### 1) Fetch the **Sysdig Trusted Identity** and **ExternalID**

These can be fetched in a single call to retrive the `TrustRelationshipPolicy` that will be used when creating an IAM role below.

```shell
$ curl -s 'https://<SYSDIG_SECURE_ENDPOINT>/api/cloud/v2/aws/trustedRoleDoc' \
--header 'Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>'
```

Response pattern:
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

## Provision your AWS Account

### 1) Create IAM Role

Sysdig secures your cloud environment by assuming an IAM Role you create within your AWS Account.

1) Create a new IAM Role with a Custom trust policy. Set the value of the trust polity to the `TrustRelationshipPolicy` policy retrieved above.
2) Attach the `arn:aws:iam::aws:policy/SecurityAudit` AWS managed policy.
3) Give the role a unique name, and take note of this name for use later on.
4) Add Tags and a Description as desired.

## Provision Sysdig

### 1) Create an AWS **account** representation

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
The response to this call will look something like:
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
<br/>

### 2) Create a Trust Relationship **component**

In this call, replace `<CLOUD_ACCOUNT_ID>` with the `id` field retrieved from the response in step 1. 
Replace `<ROLE_NAME>` with the name of the IAM role created above. Note this is not the ARN, but the role name.

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
<br/>

### 3) Create a CSPM **feature** representation

As before, replace `<CLOUD_ACCOUNT_ID>` with the `id` field retrieved from the response in step 1.
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
<br/>

## Validation


Verify that your installation was successful by following these [CSPM Validation steps](https://docs.sysdig.com/en/docs/installation/sysdig-secure/connect-cloud-accounts/aws/#check-cspm). 