# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Diagram, Cluster, Diagram, Edge, Node
from diagrams.aws.general import General
from diagrams.aws.management import Cloudtrail
from diagrams.aws.storage import S3, SimpleStorageServiceS3Bucket
from diagrams.aws.integration import SNS
from diagrams.aws.integration import SQS
from diagrams.aws.compute import ECS, ElasticContainerServiceService
from diagrams.aws.security import IAMRole,IAM


diagram_attr = {
    "pad":"0.25"
}

role_attr = {
   "height":"0.75",
   "width":"0.75",
   "fontsize":"8",
}

with Diagram("Sysdig Cloudvision{}(organizational usecase)".format("\n"), graph_attr=diagram_attr, filename="diagram", show=True):

    with Cluster("organization"):

        with Cluster("other accounts (member)"):
            member_accounts = [General("account-1"),General("..."),General("account-n")]

            org_member_role = IAMRole("OrganizationAccountAccessRole", **role_attr)


        with Cluster("master account"):

            
            cloudtrail          = Cloudtrail("cloudtrail", shape="plaintext")
            cloudtrail_legend = ("for clarity purpose events received from cloudvision member account\n\
                                    and master account have been removed from diagram, but will be processed too ")
            Node(label=cloudtrail_legend, width="5",shape="plaintext", labelloc="t", fontsize="8")


            master_credentials = IAM("master-credentials \n permissions: cloudtrail, role creation", fontsize="8")
            cloudvision_role    = IAMRole("Sysdig-Cloudvision-Role", **role_attr)
            master_credentials - cloudvision_role
            cloudtrail_s3       = S3("cloudtrail")
            sns                 = SNS("cloudtrail-sns-events", comment="i'm a graph")

            cloudtrail >> cloudtrail_s3
            cloudtrail >> sns

        with Cluster("cloudvision account (member)"):

            org_member_role = IAMRole("OrganizationAccountAccessRole", **role_attr) 

            with Cluster("ecs"):
                ecs = ECS("cloudvision")
                cloud_connect = ElasticContainerServiceService("cloud-connect")
                ecs - cloud_connect

            sqs = SQS("cloudtrail-sqs")
            s3_config = S3("cloud-connect-config")

            sqs << cloud_connect
            cloud_connect - s3_config


        member_accounts >> Edge(color="darkgreen", style="dashed") >>  cloudtrail
        sns >> Edge(color="firebrick", style="dashed") >> sqs
        cloudtrail_s3 - cloud_connect
