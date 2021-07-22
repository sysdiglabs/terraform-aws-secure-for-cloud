# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Diagram, Cluster, Diagram, Edge, Node
from diagrams.aws.general import General
from diagrams.aws.management import Cloudtrail
from diagrams.aws.storage import S3, SimpleStorageServiceS3Bucket
from diagrams.aws.integration import SNS
from diagrams.aws.integration import SQS
from diagrams.aws.compute import ECS, ElasticContainerServiceService
from diagrams.aws.security import IAMRole


with Diagram("Sysdig Cloudvision{}(organizational usecase)".format("\n"), filename="diagram", show=True):

    with Cluster("organization"):

        with Cluster("other accounts (member)"):
            member_accounts = [General("account-1"),General("..."),General("account-n")]

            org_member_role = IAMRole("OrganizationAccountAccessRole", width="1")


        with Cluster("master account"):

            cloudtrail_legend = ("* for clarity purpose events received from cloudvision member account{}\
                    and master account have been removed from diagram, but will be processed too ")

            Node(label=cloudtrail_legend.format("\n"), width="10",shape="plaintext", labelloc="\l")

            cloudvision_role    = IAMRole("Sysdig-Cloudvision-Role", width="1")
            cloudtrail          = Cloudtrail("cloudtrail *", shape="plaintext")
            cloudtrail_s3       = S3("cloudtrail-s3-data")
            sns                 = SNS("cloudtrail-sns-events")

            cloudtrail >> cloudtrail_s3
            cloudtrail >> sns

        with Cluster("cloudvision account (member)"):

            org_member_role = IAMRole("OrganizationAccountAccessRole", width="1")

            with Cluster("ecs"):
                ecs = ECS("cloudvision")
                cloud_connect = ElasticContainerServiceService("cloud-connect")
                ecs - cloud_connect

            sqs = SQS("cloudtrail-sqs")
            s3_config = SimpleStorageServiceS3Bucket("cloud-connect-config")

            sqs << cloud_connect
            s3_config - cloud_connect


        member_accounts >> Edge(color="darkgreen", style="dashed") >>  cloudtrail
        sns >> Edge(color="firebrick", style="dashed") >> sqs
        cloud_connect >> cloudtrail_s3
