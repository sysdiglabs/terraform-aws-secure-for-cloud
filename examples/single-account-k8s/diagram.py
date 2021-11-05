# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Cluster, Diagram, Edge, Node
from diagrams.aws.general import General
from diagrams.aws.compute import EKS, ECR
from diagrams.aws.devtools import Codebuild
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



with Diagram("Sysdig Secure for Cloud{}(single-account-k8s)".format("\n"), graph_attr=diagram_attr, filename="diagram", show=True, direction="RL"):

    with Cluster("AWS account (target)"):

        with Cluster("other resources", graph_attr={"bgcolor":"lightblue"}):
            account_resources = [General("resource-1..n")]
            ecr = ECR("container-registry")

        with Cluster("sysdig-secure-for-cloud resources"):
            management_credentials  = IAM("credentials", fontsize="10")

            cloudtrail          = Cloudtrail("cloudtrail", shape="plaintext")
            sns                 = SNS("sns")
            sqs                 = SQS("sqs")
            cloudtrail >> Edge(color=color_event) >> sns << sqs

            with Cluster(""):
                eks = EKS("EKS\n(pre-existing)")
                with Cluster("namespace: sfc"):
                    cc_deployment = Deployment("cloud-connector")
                    cloud_scanning = Deployment("cloud-scaner")
                    eks_deployments = [cc_deployment, cloud_scanning]


            eks_deployments >> Edge(color=color_sysdig, style="dashed") >> sqs

            # scanning
            codebuild = Codebuild("Build-project")
            cloud_scanning >> codebuild
            codebuild >> Edge(color=color_non_important) >>  ecr

        account_resources >> Edge(color=color_event, style="dashed", label="Events") >>  cloudtrail

    with Cluster("AWS account (sysdig)"):
        sds = Custom("Sysdig Secure", "../../resources/diag-sysdig-icon.png")

    eks_deployments >> Edge(color=color_sysdig) >> sds
