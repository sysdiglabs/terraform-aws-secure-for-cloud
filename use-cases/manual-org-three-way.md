# Multi-AWS Accounts with Organizational CloudTrail and SNS with S3 

This use case describes setting up Secure for Cloud for a multi-AWS accounts environment with the following:

- AWS Management account with Organization CloudTrail
- AWS account with Amazon Simple Notification Service (SNS) and Amazon S3 is cloud object storage

This setup will provide the following [Sysdig Secure for Cloud](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/) features:

- [Threat Detection](https://docs.sysdig.com/en/docs/sysdig-secure/policies/threat-detect-policies/)
- [Posture](https://docs.sysdig.com/en/docs/sysdig-secure/posture/)
- [Compliance](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/)
- [Identity Access Management](https://docs.sysdig.com/en/docs/sysdig-secure/posture/identity-and-access/)

## Prerequisites 

- The following event ingestion resources created in the same AWS regions: 

  - AWS Organizational Management account

    - Cloudtrail with SNS activated

      For more information, see [Configuring Amazon SNS notifications for CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/configure-sns-notifications-for-cloudtrail.html).

      See the **account-management** module in the diagram given below.

  - AWS member account for logging

    - Cloudtrail-enabled S3 bucket

      For more information, see [CloudTrail event logging for S3 buckets](https://docs.aws.amazon.com/AmazonS3/latest/userguide/enable-cloudtrail-logging-for-s3.html).

      See the **account-logging** module in the diagram given below.


  See the **account-management** and **account-logging** modules (`cloudtrail-sns` and `cloudtrail-s3` bucket) in the diagram given below. 

- AWS member account for Sysdig (`SYSDIG_ACCOUNT_ID`)

  - EKS or ECS cluster to deploy Sysdig Secure for Cloud (Cloud Connector)

    See **account-management** and **account-security** modules in the diagram given below.

- AWS member account for Compliance

  - Sysdig Compliance Role:`aws:SecurityAudit policy`.  

    For more information, see [Creating IAM roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create.html).

    This IAM Role provisions permissions pertaining to enable audit trail for compliance. 

    See the **account-compliance** module in the diagram given below.



## Overview 

In this setup, you will do the following:

[three-way k8s setup](./resources/org-three-way-with-sns.png)

-  AWS user account for logging:  In this account, you will create the Sysdig Access S3 Role,`SysdigS3AccessRole`, to retrieve data from the Cloudtail-enabled S3 bucket.

- AWS user account for Sysdig: In this account, you will create the following:

  - Sysdig Compute Role: `ARN_SYSDIG_COMPUTE_ROLE` as given in [Create Compute Role](#create-sysdig-compute-role). 

    See the **account-security** modules in the diagram given below.

  - A topic for `cloudtrail-sns-sqs` setting from the organizational Cloudtrail into Cloud Connector compute module. 

We recommend that you perform the operations in the following order:

1. Deploy the Cloud Connector. This configuration enables Threat Detection.
2. Configure the Compliance role, `aws:SecurityAudit policy`,  if required.

## Create Sysdig Compute Role

To fetch data from the S3 bucket, you create a role named `SysdigComputeRole` and attach it to the compute service. Then, you download the ARN and save its as`ARN_SYSDIG_COMPUTE_ROLE`.

1. Create `SysdigComputeRole` in your cluster. 

2. Enable it to be used from within. 

3. Do the following:

   **EKS** cluster: Use the IAM authentication role mapping setup. 

   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Principal": {
                   "Service": "eks.amazonaws.com"
               },
               "Action": "sts:AssumeRole"
           }
       ]
   }
   ```

   

   **ECS**: Allow Trust relationship for the ECS Task usage.

   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Sid": "",
               "Effect": "Allow",
               "Principal": {
                   "Service": "ecs-tasks.amazonaws.com"
               },
               "Action": "sts:AssumeRole"
           }
       ]
   }
   ```

   For more information, see [Creating IAM roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create.html).

4. Save the `ARN_SYSDIG_COMPUTE_ROLE`.

## Configure the Cloud Connector 

The Sysdig Cloud Connector is a component in Sysdig Secure for Cloud that checks for cloud security issues based on rules defined on Sysdig Secure. This enables compliance and auditing for your cloud-based accounts.

CloudTrail periodically writes log files to the S3 bucket you have configured. When each file is written, it also sends an SNS notification. SQS is subscribing to the notification will hold them until they are processed by Cloud Connector.

The Cloud Connector uses the Cloudtrail ingestion to consume organizational events.

To enable it, you configure the following:

- SQS to ingest the events

- Cloudtrail-enabled S3 bucket to allow cross-account read

### Prepare SQS

1. Verify that SNS notification is activated for your organizational Cloudtrail.

   See the **account-management** module in the diagram above.

   For more information, see [Configuring Amazon SNS notifications for CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/configure-sns-notifications-for-cloudtrail.html).

2. On your cluster, where Sysdig is deployed, create an SQS topic to ingest Cloudtrail events.

   1. Use the default configuration parameters

   2. Due to cross-account limitations, enable `SNS:Subscribe` permissions on the queue:

      ```json
      {
        "Sid": "AllowCrossAccountSNSSubscription",
        "Effect": "Allow",
        "Principal": {
          "AWS": "<ARN_SUBSCRIPTION_ACTION_USER>"
        },
        "Action": "sns:Subscribe",
        "Resource": "<ARN_CLOUDTRAIL_SNS>"
      }
      ```

      For example:

      ```
      {
        "Version": "2012-10-17",
        "Id": "__default_policy_ID",
        "Statement": [
          {
            "Sid": "AllowCrossAccountSNSSubscription",
            "Effect": "Allow",
            "Principal": {
              "AWS": "237944556329"
            },
            "Action": "sns:Subscribe",
            "Resource": "arn:aws:sqs:us-east-2:237944556329:SYSDIG_CLOUDTRAIL_SNS_SQS"
          }
        ]
      }
      ```

      

      This will enable Cloudtrail-SNS topic to subscribe to the SQS queue.

   3. Configure the Cloudtrail-SNS topic to subscribe to the SQS queue.

   4. Save `SYSDIG_CLOUDTRAIL_SNS_SQS_URL` and `ARN_CLOUDTRAIL_SNS_SQS` for later use.


4. Configure the cross-aacount S3 access credentials.

     1. In the organizational account where Cloudtrail-S3 bucket is placed, create a new `SysdigS3AccessRole` role to
        handle the following permissions and save it as `ARN_ROLE_SYSDIG_S3_ACCESS`.

        ```yaml
        {
            "Sid": "AllowSysdigReadS3",
            "Effect": "Allow",
            "Action": [
              "s3:GetObject"
            ],
            "Resource": "<ARN_CLOUDTRAIL_S3>/*"
        }
        ```

        

     2. Perform the same permissions setup on the S3 bucket. Add following statement to the Bucket policy:

        ```yaml
        {
            "Sid": "AllowSysdigReadS3",
            "Effect": "Allow",
            "Principal": {
              "AWS": "<ARN_ROLE_SYSDIG_S3_ACCESS>"
            },
            "Action": "s3:GetObject",
            "Resource": "<ARN_CLOUDTRAIL_S3>/*"
         }
        ```

        

     3. Allow cross-account `assumeRole` Trust Relationship, for Sysdig Compute role to be able to make
        use of this `SysdigS3AccessRole`:

        ```yaml
        {
        "Sid": "AllowSysdigAssumeRole",
        "Effect": "Allow",
        "Principal": {
        "AWS": "<ARN_SYSDIG_COMPUTE_ROLE>"
        },
        "Action": "sts:AssumeRole"
        }	
        ```

   

## Secure for Cloud Compute Deployment

In the `SYSDIG_ACCOUNT_ID` account.

We will setup the `SysdigComputeRole`, to be able to perform required actions by Secure for Cloud
compute; work with the SQS and access S3 resources (this last one via assumeRole).

```json
{
    "Version": "2012-10-17",
    "Statement": [
	    {
            "Effect": "Allow",
            "Action": [
                "SQS:ReceiveMessage",
                "SQS:DeleteMessage"
            ],
            "Resource": "<ARN_CLOUDTRAIL_SNS_SQS>"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "<ARN_SYSDIG_S3_ACCESS_ROLE>"
        }
    ]
}
```

Now we will deploy the compute component, depending on the compute service

#### EKS


<!--

1. Kubernetes **Credentials** creation
   - This step is not really required if Kubernetes role binding is properly configured for the deployment, with an
     IAM role with required permissions listed in following points.
   - Otherwise, we will create an AWS user `SYSDIG_K8S_USER_ARN`, with `SYSDIG_K8S_ACCESS_KEY_ID` and
     `SYSDIG_K8S_SECRET_ACCESS_KEY`, in order to give Kubernetes compute permissions to be able to handle S3 and SQS operations
   - Secure for Cloud [does not manage IAM key-rotation, but find some suggestions to rotate access-key](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/infrastructure/permissions/iam-user#access-key-rotation)<br/><br/>
     -->


If using Kubernetes, we will make use of the [Sysdig cloud-connector helm chart](https://charts.sysdig.com/charts/cloud-connector/) component.
<br/>Locate your `<SYSDIG_SECURE_ENDPOINT>` and `<SYSDIG_SECURE_API_TOKEN>`.<br/> [Howto fetch ApiToken](https://docs.sysdig.com/en/docs/administration/administration-settings/user-profile-and-password/retrieve-the-sysdig-api-token)

Provided the following `values.yaml` template

```yaml
sysdig:
  url: "https://secure.sysdig.com"
  secureAPIToken: "SYSDIG_API_TOKEN"
telemetryDeploymentMethod: "helm_aws_k8s_org"		# not required but would help us
aws:
    region: <SQS-AWS-REGION>
ingestors:
    - cloudtrail-sns-sqs:
        queueURL:"<URL_CLOUDTRAIL_SNS_SQS>"             # step 3
        assumeRole:"<ARN_ROLE_SYSDIG_S3_ACCESS>"        # step 4
```

We will install it

```shell
$ helm upgrade --install --create-namespace -n sysdig-cloud-connector sysdig-cloud-connector sysdig/cloud-connector -f values.yaml
```

Test it

```shell
$ kubectl logs -f -n sysdig-cloud-connector deployment/sysdig-cloud-connector
```

And if desired uninstall it

```shell
$ helm uninstall -n sysdig-cloud-connector sysdig-cloud-connector
```

#### ECS

If using , AWS ECS (Elastic Container Service), we will create a new Fargate Task.

- TaskRole: Use previously created `SysdigComputeRole`

- Task memory (GB): 0.5 and Task CPU (vCPU: 0.25 will suffice

- Container definition

  - Image: `quay.io/sysdig/cloud-connector:latest`

  - Port Mappings; bind port 5000 tcp protocol

  - Environment variables

    - SECURE_URL
    - SECURE_API_TOKEN
    - CONFIG:  A base64 encoded configuration of the cloud-connector service

    ```yaml
    logging: info
    rules: []
    ingestors:
        - cloudtrail-sns-sqs:
            queueURL: <URL_CLOUDTRAIL_SNS_SQS>
            assumeRole: <ARN_ROLE_SYSDIG_S3_ACCESS>
    ```

    <!--

AWS Systems Manager
Application Manager
CustomGroup: iru


AWS::SSM::Parameter
Type: SecureString
Data type: text

In ContainerDefinition, secrets

- SECURE_API_TOKEN, `secretName`

ExecutionRole
{
"Version": "2012-10-17",
"Statement": [
{
"Sid": "",
"Effect": "Allow",
"Action": "ssm:GetParameters",
"Resource": "arn:aws:ssm:eu-west-3:**:parameter/**"
}
]
}
-->


## Verify Configuration

Check within Sysdig Secure

- Integrations > Cloud Accounts
- Insights > Cloud Activity

- [Official Docs Check Guide](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-gcp/#confirm-the-services-are-working)
- [Forcing events](https://github.com/sysdiglabs/terraform-google-secure-for-cloud#forcing-events)
