# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Cluster, Diagram, Edge, Node
from diagrams.aws.compute import ElasticContainerServiceService
from diagrams.aws.devtools import Codebuild
from diagrams.aws.general import General
from diagrams.aws.integration import SNS, SQS
from diagrams.aws.management import Cloudtrail, Cloudwatch
from diagrams.aws.security import IAM, IAMRole
from diagrams.aws.storage import S3
from diagrams.custom import Custom

diagram_attr = {
    "pad":"0.25"
}

role_attr = {
   "height":"1",
   "width":"0.8",
   "fontsize":"9",
}

event_color="firebrick"

with Diagram("Sysdig Secure for Cloud\n(organizational usecase)", graph_attr=diagram_attr, filename="diagram-org", show=True):

    with Cluster("AWS organization"):

        with Cluster("member accounts (main targets)", graph_attr={"bgcolor":"lightblue"}):
            member_accounts = [General("account-1"), General("account-2"), General("..."), General("account-n")]

            org_member_role = IAMRole("OrganizationAccountAccessRole\n(created by AWS for org. member accounts)", **role_attr)


        with Cluster("master account"):


            cloudtrail              = Cloudtrail("cloudtrail", shape="plaintext")
            cloudtrail_legend       = ("for clarity purpose events received from 'secure for cloud' member account\n\
                                    and master account have been removed from diagram, but will be processed too ")

            Node(label=cloudtrail_legend, width="5",shape="plaintext", labelloc="t", fontsize="10")

            master_credentials      = IAM("credentials \npermissions: cloudtrail, role creation,...", fontsize="10")
            secure_for_cloud_role   = IAMRole("SysdigSecureForCloudRole", **role_attr)
            cloudtrail_s3           = S3("cloudtrail-s3-events")
            sns                     = SNS("cloudtrail-sns-events", comment="i'm a graph")

            cloudtrail >> Edge(color=event_color, style="dashed") >> cloudtrail_s3 >> Edge(color=event_color, style="dashed") >> sns



        with Cluster("member account (secure for cloud)", graph_attr={"bgcolor":"seashell2"}):

            org_member_role = IAMRole("OrganizationAccountAccessRole\n(created by AWS for org. member accounts)", **role_attr)

            with Cluster("ecs-cluster"):
                cloud_connector = ElasticContainerServiceService("cloud-connector")
                cloud_scanning = ElasticContainerServiceService("cloud-scanning")

            sqs         = SQS("cloudtrail-sqs")
            s3_config   = S3("cloud-connector-config")
            cloudwatch  = Cloudwatch("cloudwatch\nlogs and alarms")
            codebuild = Codebuild("codebuild project")

            sqs << Edge(color=event_color) << cloud_connector
            sqs << Edge(color=event_color) << cloud_scanning
            cloud_connector - s3_config
            cloud_connector >> cloudwatch
            cloud_scanning >> codebuild


        member_accounts >> Edge(color=event_color, style="dashed") >>  cloudtrail
        sns >> Edge(color=event_color, style="dashed") >> sqs
#        cloudtrail_s3 << Edge(color=event_color) << cloud_connector
        (cloudtrail_s3 << Edge(color=event_color) << secure_for_cloud_role) -  Edge(xlabel="assumeRole", color=event_color) - cloud_connector

    with Cluster("AWS account (sysdig)"):
        sds = Custom("Sysdig Secure", "../../resources/diag-sysdig-icon.png")

    cloud_connector >> sds
    codebuild >> sds
