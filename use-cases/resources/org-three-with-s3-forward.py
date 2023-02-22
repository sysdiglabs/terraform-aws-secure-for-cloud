# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Cluster, Diagram, Edge, Node
from diagrams.aws.general import General
from diagrams.aws.management import Cloudtrail
from diagrams.aws.integration import SNS
from diagrams.aws.storage import S3
from diagrams.aws.integration import SQS
from diagrams.aws.compute import ECS
from diagrams.aws.security import IAM, IAMRole

color_event="firebrick"

with Diagram("Three-Way Cross-Account", filename="org-three-with-s3-forward", show=True):

    with Cluster("management account - cloudtrail"):
        cloudtrail = Cloudtrail("cloudtrail\n(no sns activated)")
        #org_role = IAM("sfc-SysdigSecureForCloudRole")

    with Cluster("member account - cloudtrail S3 bucket"):
        cloudtrail_s3 = S3("cloudtrail-s3")
        cloudtrail_sns_sqs = SQS("cloudtrail-s3-sns-sqs\nevent forward")
        org_role = IAM("SysdigSecureForCloud-S3AccessRole")

    with Cluster("member account - SFC compute"):
        ecs = ECS("sfc")
        ecs_role = IAM("sfc-organizational-ECSTaskRole")
        ecs - ecs_role

    cloudtrail >> cloudtrail_s3
    cloudtrail_s3 >> cloudtrail_sns_sqs

    ecs_role >> Edge(color=color_event, style="dashed", label="sts:AssumeRole") << org_role
    ecs_role >> Edge(color=color_event, style="dashed", label="sqs:Receive+Delete")  << cloudtrail_sns_sqs
    org_role >> Edge(color=color_event, style="dashed", label="s3:GetObject") << cloudtrail_s3
