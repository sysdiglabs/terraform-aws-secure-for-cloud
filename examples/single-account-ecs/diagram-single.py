# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Diagram, Cluster, Diagram, Edge, Node
from diagrams.custom import Custom
from diagrams.aws.general import General
from diagrams.aws.management import Cloudtrail
from diagrams.aws.storage import S3, SimpleStorageServiceS3Bucket
from diagrams.aws.integration import SNS
from diagrams.aws.integration import SQS
from diagrams.aws.compute import ECS, ElasticContainerServiceService, ECR
from diagrams.aws.security import IAMRole,IAM
from diagrams.aws.management import Cloudwatch
from diagrams.aws.devtools import Codebuild
from diagrams.aws.management import SystemsManager


diagram_attr = {
    "pad":"1.25"
}


role_attr = {
   "imagescale":"true",
   "width":"2",
   "fontsize":"13",
}


color_event="firebrick"
color_scanning = "dark-green"
color_permission="steelblue3"
color_non_important="gray"
color_sysdig="lightblue"

with Diagram("Sysdig Secure for Cloud{}(single-account-ecs)".format("\n"), graph_attr=diagram_attr, filename="diagram-single", show=True):

    public_registries = Custom("Public Registries","../../resources/diag-registry-icon.png")


    with Cluster("AWS single-account-ecs"):

        master_credentials = IAM("credentials \npermissions: cloudtrail, role creation,...", fontsize="10")

        with Cluster("other resources", graph_attr={"bgcolor":"lightblue"}):
            account_resources = [General("resource-1..n")]
            ecr = ECR("container-registry\n*sends events on image push to cloudtrail\n*within any account")

            with Cluster("ecs-cluster"):
              ecs_services = ElasticContainerServiceService("other services\n*sends events with image runs to cloudtrail")

        with Cluster("sysdig-secure-for-cloud resources"):

            # cloudtrail
            cloudtrail              = Cloudtrail("cloudtrail\n* ingest events from all\norg member accounts+managed", shape="plaintext")
#            cloudtrail_legend = ("for clarity purpose events received from sysdig-secure-for-cloud resources\nhave been removed from diagram, but will be processed too")
#            Node(label=cloudtrail_legend, width="5",shape="plaintext", labelloc="t", fontsize="10")

            cloudtrail_s3       = S3("cloudtrail-s3-events")
            sns                 = SNS("cloudtrail-sns-events", comment="i'm a graph")
            cloudwatch = Cloudwatch("cloudwatch\n(logs and alarms)")


            cloudtrail >> Edge(color=color_event, style="dashed") >> cloudtrail_s3
            cloudtrail >> Edge(color=color_event, style="dashed") >> sns

            with Cluster("ecs-cluster"):
                cloud_connector = ElasticContainerServiceService("cloud-connector")

            sqs = SQS("cloudtrail-sqs")
            sqs << Edge(color=color_event) << cloud_connector
            cloud_connector >> Edge(color=color_non_important) >>  cloudwatch

            # scanning
            codebuild = Codebuild("Build-project")
            cloud_connector >> Edge(color=color_non_important) >> cloudwatch
            cloud_connector >> codebuild
            codebuild >> Edge(color=color_non_important) >>  ecr
            codebuild >> Edge(color=color_non_important) >>  public_registries


            # bench-role
            cloud_bench_role = IAMRole("SysdigCloudBench\n(aws:SecurityAudit policy)", **role_attr)

        #account_resources >> Edge(color=color_event, style="dashed") >>  cloudtrail
        sns >> Edge(color=color_event, style="dashed") >> sqs
        (cloudtrail_s3 << Edge(color=color_non_important)) -  cloud_connector

    with Cluster("AWS account (sysdig)"):
        sds = Custom("Sysdig Secure\n*receives cloud-connector and cloud-build results\n*assumeRole on SysdigCloudBench", "../../resources/diag-sysdig-icon.png")
        sds_account = General("cloud-bench")
        sds - Edge(label="aws_foundations_bench\n schedule on rand rand * * *") >>  sds_account


    cloud_connector >> Edge(color=color_sysdig) >> sds
    codebuild >> Edge(color=color_sysdig) >>  sds
    sds_account >> Edge(color=color_permission, fontcolor=color_permission) >> cloud_bench_role
