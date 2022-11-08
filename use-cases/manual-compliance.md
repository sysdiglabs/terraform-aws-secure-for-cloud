# Compliance

On each account where compliance wants to be checked (`AWS_ACCOUNT_ID`), we need to provide a role for Sysdig to be able to impersonate and perform `SecurityAudit` tasks.

In addition, we must make Sysdig aware of these accounts and role.
We will guide you to provide, on the Sysdig Secure SaaS backend, the following resources:
- a cloud-account for each account of your organization where compliance is wanted to be checked
- a task that will run `aws_foundations_bench-1.3.0` schema on previously defined accounts

## Sysdig Side

1. **Register cloud accounts** on Sysdig

For each account you want to provision for the Compliance feature, we need to register it on Sysdig Secure, so
it can impersonate and perform `SecurityAudit` tasks.

For Sysdig Secure backend API communication [How to use development tools](https://docs.sysdig.com/en/docs/developer-tools/). Also, we have this [AWS provisioning script](./utils/sysdig_cloud_compliance_provisioning.sh) as reference, but we will explain it here too.
```shell
$ curl "https://<SYSDIG_SECURE_ENDPOINT>/api/cloud/v2/accounts?upsert=true" \
--header "Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>" \
-X POST \
-H 'Accept: application/json' \
-H 'Content-Type: application/json' \
-d '{
 "accountId": "<AWS_ACCOUNT_ID>",
 "alias": "<AWS_ACCOUNT_ALIAS>",
 "provider": "aws",
 "roleAvailable": true,
 "roleName": "SysdigComplianceRole"
}'
```
<br/>

2. Register **Benchmark Task**

Create a single task to scope the organization account ids (or just a single account) to be assessed with the
`aws_foundations_bench-1.3.0` compliance framework.

This script does not cover it, but specific regions can be scoped too. Check `Benchmarks-V2` REST-API for more detail
```shell
$ curl -s "https://<SYSDIG_SECURE_ENDPOINT>/api/benchmarks/v2/tasks" \
--header "Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>" \
-X POST \
-H 'Accept: application/json' \
-H 'Content-Type: application/json' \
-d '{
  "name": "Sysdig Secure for Cloud (AWS) - Organization",
  "schedule": "0 3 * * *",
  "schema": "aws_foundations_bench-1.2.0",
  "scope": "aws.accountId in ('<AWS_ACCOUNT_ID_1>',...,'<AWS_ACCOUNT_ID_N>')'",
  "enabled": true
}'
```

<br/>

3. Get **Sysdig Federation Trusted Identity**

For later usage, fetch the Trusted Identity `SYSDIG_AWS_TRUSTED_IDENTITY_ARN`

```shell
$ curl -s 'https://<SYSDIG_SECURE_ENDPOINT>/api/cloud/v2/aws/trustedIdentity' \
--header 'Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>'
```

   Response pattern:
```shell
arn:aws:iam::SYSDIG_AWS_ACCOUNT_ID:role/SYSDIG_AWS_ROLE_NAME
```

<br/>

4. Get **Sysdig ExternalId**

For later usage, fetch `SYSDIG_AWS_EXTERNAL_ID` from one of the previously registered GCP accounts. All accounts will have same id (you only need to run it once).
```shell
$ curl -s "https://<SYSDIG_SECURE_ENDPOINT>/api/cloud/v2/accounts/<AWS_ACCOUNT_ID>?includeExternalId=true" \
--header "Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>"
```
From the resulting payload get the `externalId` attribute value.

<br/>

## Customer's Side

Now create `SysdigCompliance` role on each account using the values gathered in previous step.
  - Add `arn:aws:iam::aws:policy/SecurityAudit` AWS managed policy
  - Allow following Trusted-Identity
    ```json
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": [ "<SYSDIG_AWS_TRUSTED_IDENTITY_ARN>" ]
      },
      "Condition": {
        "StringEquals": {"sts:ExternalId": "<SYSDIG_AWS_EXTERNAL_ID>"}
      }
    }
    ```

## End-To-End Validation

Validate if Sysdig <-> Customer infra connection is properly made using [`/cloud/accounts/{accountId}/validateRole`](https://secure.sysdig.com/swagger.html#tag/Cloud/paths/~1api~1cloud~1v2~1accounts~1{accountId}~1validateRole/get)

```bash
$ https://<SYSDIG_SECURE_ENDPOINT>/api/cloud/v2/accounts/<AWS_ACCOUNT_ID>/validateRole \
--header 'Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>'
```

You should get success or the reason of failure.


## Testing

Check within Sysdig Secure
- Posture > Compliance  for the compliance task schedule
- [Official Docs Check Guide](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-aws/#confirm-the-services-are-working)
