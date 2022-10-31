# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Cluster, Diagram, Edge, Node
from diagrams.aws.general import General
from diagrams.aws.management import Cloudtrail
from diagrams.aws.integration import SNS
from diagrams.aws.storage import S3
from diagrams.aws.integration import SQS
from diagrams.aws.compute import EKS
from diagrams.aws.security import IAM, IAMRole

color_event="firebrick"

with Diagram("Permission Schema", filename="manual-org-three-way.png", show=True):

    with Cluster("account - management"):
        cloudtrail = Cloudtrail("cloudtrail (organizational)")
        cloudtrail_sns = SNS("cloudtrail-sns")
        cloudtrail - cloudtrail_sns


    with Cluster("account - compute"):
        cloudtrail_sns_sqs = SQS("cloudtrail-sns-sqs")
        eks = EKS()
        eks_role = IAM("SysdigComputeRole")
        eks - eks_role


    with Cluster("account - cloudtrail S3 bucket"):
         cloudtrail_s3 = S3("cloudtrail-s3")

         s3_role = IAM("cloudtrail-s3 role")
         s3_role >> Edge(color=color_event, style="dashed", label="s3:GetObject") << cloudtrail_s3


    cloudtrail - cloudtrail_s3
    cloudtrail_sns - cloudtrail_sns_sqs

    eks_role >> Edge(color=color_event, style="dashed", xlabel="sts:AssumeRole\n+TrustedEntity") << s3_role
    eks_role >> Edge(color=color_event, style="dashed", label="sqs:Receive+Delete")  << cloudtrail_sns_sqs