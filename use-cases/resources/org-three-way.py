# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Cluster, Diagram, Edge, Node
from diagrams.aws.general import General
from diagrams.aws.management import Cloudtrail
from diagrams.aws.integration import SNS
from diagrams.aws.storage import S3
from diagrams.aws.integration import SQS
from diagrams.aws.compute import ECS
from diagrams.aws.compute import EKS
from diagrams.aws.security import IAM, IAMRole
from diagrams.k8s.group import Namespace
from diagrams.k8s.compute import Deployment

color_event="firebrick"

with Diagram("Three-Way Cross-Account", filename="org-three-way", show=True):

    with Cluster("management account - cloudtrail"):
        cloudtrail = Cloudtrail("cloudtrail")
        cloudtrail_sns = SNS("cloudtrail-sns")

        cloudtrail - cloudtrail_sns

    with Cluster("member account - logging"):
        cloudtrail_s3 = S3("cloudtrail-s3")
        org_role = IAM("SysdigCrossAccountS3Access")

        org_role - cloudtrail_s3

    with Cluster("member account - SFC compute"):
        with Cluster("K8s Cluster\n(pre-existing)"):
            cloud_connector = Deployment("cloud-connector")
        k8s_iam = IAM("SysdigK8sUser/Role")
        cloudtrail_sns_sqs = SQS("cloudtrail-sns-sqs")
        cloud_connector - k8s_iam

    cloudtrail - cloudtrail_s3
    cloudtrail_sns - cloudtrail_sns_sqs

    k8s_iam >> Edge(color=color_event, style="dashed", label="sts:AssumeRole + TrustedIdentity") << org_role
    k8s_iam >> Edge(color=color_event, style="dashed", label="sqs:Receive+Delete")  << cloudtrail_sns_sqs
    k8s_iam >> Edge(color=color_event, style="dashed", label="s3:GetObject") << org_role
