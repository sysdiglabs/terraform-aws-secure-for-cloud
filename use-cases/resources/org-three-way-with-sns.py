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
from diagrams.custom import Custom

color_event="firebrick"

with Diagram("Organizational Three-Way Cross-Account Setup", filename="org-three-way-with-sns", show=True):


    with Cluster("AWS account (sysdig)", graph_attr={"bgcolor": "lightblue"}):
        sds = Custom("Sysdig Secure", "../../resources/diag-sysdig-icon.png")
        bench = General("Cloud Bench")
        sds >> Edge(label="schedule on rand rand * * *") >> bench

    with Cluster("AWS Organization"):
        with Cluster("account - management"):
            cloudtrail = Cloudtrail("cloudtrail")
            cloudtrail_sns = SNS("cloudtrail-sns")

            cloudtrail - cloudtrail_sns

        with Cluster("account2 - logging"):
            cloudtrail_s3 = S3("cloudtrail-s3")
            s3_role = IAM("SysdigS3AccessRole")

        with Cluster("account - security"):
            with Cluster("EKS/ECS Cluster"):
                cloud_connector = Deployment("cloud-connector")
            cluster_role = IAM("SysdigComputeRole")
            cloudtrail_sns_sqs = SQS("cloudtrail-sns-sqs")
            cloud_connector - cluster_role

        cloudtrail - cloudtrail_s3
        cloudtrail_sns - cloudtrail_sns_sqs

        cluster_role >> Edge(color=color_event, style="dashed", xlabel="sts:AssumeRole\n+TrustedEntity") << s3_role
        cluster_role >> Edge(color=color_event, style="dashed", label="sqs:Receive+Delete")  << cloudtrail_sns_sqs
        s3_role >> Edge(color=color_event, style="dashed", label="s3:GetObject")  << cloudtrail_s3

        with Cluster("account(s) - compliance"):
            ccBenchRoleOnEachProject = IAM("Sysdig Compliance Role\n(aws:SecurityAudit policy)")
            bench >> ccBenchRoleOnEachProject
