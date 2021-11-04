# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Cluster, Diagram, Edge, Node
from diagrams.aws.compute import EKS
from diagrams.aws.general import General
from diagrams.aws.integration import SNS, SQS
from diagrams.aws.management import Cloudtrail
from diagrams.aws.security import IAM, IAMRole
from diagrams.aws.storage import S3
from diagrams.custom import Custom

from diagrams.k8s.group import Namespace
from diagrams.k8s.compute import Deployment

diagram_attr = {
    "pad":"0.25"
}

role_attr = {
   "imagescale":"false",
   "height":"1.5",
   "width":"3",
   "fontsize":"9",
}

color_event="firebrick"
color_scanning = "dark-green"
color_permission="red"
color_creates="darkblue"
color_non_important="gray"
color_sysdig="lightblue"



with Diagram("Sysdig Secure for Cloud{}(org-threat_detection-k8s-cloudtrail_s3_sns_sqs-eks)".format("\n"), graph_attr=diagram_attr, filename="diagram", show=True, direction="TB"):

    with Cluster("AWS organization"):

        with Cluster("member accounts (main targets)", graph_attr={"bgcolor":"lightblue"}):
            member_accounts = General("account-1..n")


        with Cluster("member account (secure for cloud)", graph_attr={"bgcolor":"seashell2"}):
            member_account = General("member account")
            management_credentials  = IAM("credentials", fontsize="10")
            eks = EKS("pre-existing EKS")
            cc_deployment = Deployment("cloud-connector (ns: sfc)")
            eks - cc_deployment


        with Cluster("management account"):

            with Cluster("Events"):
                cloudtrail          = Cloudtrail("cloudtrail", shape="plaintext")
                cloudtrail_s3       = S3("cloudtrail-s3-events")
                sns                 = [SNS("sns /path-1"), SNS("sns /path-2"), SNS("sns /path-n")]
                sqs                 = SQS("sqs")

            cloudtrail >> Edge(color=color_event) >> cloudtrail_s3 >> Edge(color=color_event) >> sns >> sqs
            management_credentials  = IAM("credentials", fontsize="10")

        cc_deployment >>  Edge(color=color_event, style="dashed", label="subscribed") >> sqs
        member_accounts >> Edge(color=color_event, style="dashed") >>  cloudtrail
        member_account >>  Edge(color=color_event, style="dashed") >>  cloudtrail

    with Cluster("AWS account (sysdig)"):
        sds = Custom("Sysdig Secure", "../../resources/diag-sysdig-icon.png")

    cc_deployment >> Edge(color=color_sysdig) >> sds
