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
    "pad":"0.30"
}

role_attr = {
#   "height":"1",
#   "width":"0.9",
#   "fontsize":"10",
}


color_event="firebrick"
color_scanning = "dark-green"
color_permission="red"
color_non_important="gray"
color_sysdig="lightblue"

with Diagram("Sysdig Secure for Cloud{}(single-account)".format("\n"), graph_attr=diagram_attr, filename="diagram-single", show=True):

    with Cluster("AWS account (target)"):

        master_credentials = IAM("credentials \npermissions: cloudtrail, role creation,...", fontsize="10")

        with Cluster("other resources", graph_attr={"bgcolor":"lightblue"}):
            account_resources = [General("resource-1..n")]
            ecr = ECR("container-registry")

        with Cluster("sysdig-secure-for-cloud resources"):

            # cloudtrail
            cloudtrail          = Cloudtrail("cloudtrail", shape="plaintext")
            cloudtrail_legend = ("for clarity purpose events received from sysdig-secure-for-cloud resources\nhave been removed from diagram, but will be processed too")
            Node(label=cloudtrail_legend, width="5",shape="plaintext", labelloc="t", fontsize="10")

            cloudtrail_s3       = S3("cloudtrail-s3-events")
            sns                 = SNS("cloudtrail-sns-events", comment="i'm a graph")

            cloudtrail >> Edge(color=color_event, style="dashed") >> cloudtrail_s3 >> Edge(color=color_event, style="dashed") >> sns

            with Cluster("ecs-cluster"):
                cloud_connector = ElasticContainerServiceService("cloud-connector")
                cloud_scanning = ElasticContainerServiceService("cloud-scanning")

            sqs = SQS("cloudtrail-sqs")
            s3_config = S3("cloud-connector-config")
            cloudwatch = Cloudwatch("cloudwatch\n(logs and alarms)")

            sqs << Edge(color=color_event) << cloud_connector
            sqs << Edge(color=color_event) << cloud_scanning
            cloud_connector - Edge(color=color_non_important) - s3_config
            cloud_connector >> Edge(color=color_non_important) >>  cloudwatch

            # scanning
            codebuild = Codebuild("Build-project")
            cloud_scanning >> Edge(color=color_non_important) >> cloudwatch
            cloud_scanning >> codebuild
            codebuild >> Edge(color=color_non_important) >>  ecr


            # bench-role
            cloud_bench_role = IAMRole("SysdigCloudBench\n(aws:SecurityAudit policy)", **role_attr)

        account_resources >> Edge(color=color_event, style="dashed") >>  cloudtrail
        sns >> Edge(color=color_event, style="dashed") >> sqs
        (cloudtrail_s3 << Edge(color=color_non_important)) -  cloud_connector
        (cloudtrail_s3 << Edge(color=color_non_important)) - cloud_scanning

    with Cluster("AWS account (sysdig)"):
        sds_account = General("cloud-bench")
        sds = Custom("Sysdig Secure", "../../resources/diag-sysdig-icon.png")

        sds - Edge(label="aws_foundations_bench\n schedule on 0 6 * * *") >>  sds_account


    cloud_connector >> Edge(color=color_sysdig) >> sds
    codebuild >> Edge(color=color_sysdig) >>  sds
    sds_account >> Edge(color=color_permission, fontcolor=color_permission, xlabel="assumeRole") >> cloud_bench_role
