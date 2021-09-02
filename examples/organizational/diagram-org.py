# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Cluster, Diagram, Edge, Node
from diagrams.aws.compute import ElasticContainerServiceService, ECR
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
   "imagescale":"false",
   "height":"1.5",
   "width":"3",
   "fontsize":"9",
}

color_event="firebrick"
color_scanning = "dark-green"
color_permission="red"
color_non_important="gray"
color_sysdig="lightblue"



with Diagram("Sysdig Secure for Cloud\n(organizational)", graph_attr=diagram_attr, filename="diagram-org", show=True, direction="LR"):

    with Cluster("AWS organization"):


        with Cluster("management account"):

            cloudtrail              = Cloudtrail("cloudtrail", shape="plaintext")


            management_credentials  = IAM("credentials \npermissions: cloudtrail, role creation,...", fontsize="10")
            secure_for_cloud_role   = IAMRole("SysdigSecureForCloudRole\n\(enabled to assumeRole on `OrganizationAccountAccessRole`)", **role_attr)
            cloudtrail_s3           = S3("cloudtrail-s3-events")
            sns                     = SNS("cloudtrail-sns-events", comment="i'm a graph")

            cloudtrail >> Edge(color=color_event, style="dashed") >> cloudtrail_s3 >> Edge(color=color_event, style="dashed") >> sns

        with Cluster("member accounts (main targets)", graph_attr={"bgcolor":"lightblue"}):
            member_accounts = General("account-1..n")
            org_member_role_1 = IAMRole("OrganizationAccountAccessRole\n(created by AWS for org. member accounts)", **role_attr)
            ecr = ECR("container-registry\n *within any account")


        with Cluster("member account (secure for cloud)", graph_attr={"bgcolor":"seashell2"}):

            org_member_role_2 = IAMRole("OrganizationAccountAccessRole\n(created by AWS for org. member accounts)", **role_attr)

            sqs         = SQS("cloudtrail-sqs")
            s3_config   = S3("cloud-connector-config")
            cloudwatch  = Cloudwatch("cloudwatch\nlogs and alarms")
            codebuild   = Codebuild("codebuild project")

            with Cluster("ecs-cluster"):
                cloud_connector = ElasticContainerServiceService("cloud-connector")
                cloud_scanning = ElasticContainerServiceService("cloud-scanning")

            sqs << Edge(color=color_event) << cloud_connector
            sqs << Edge(color=color_event) << cloud_scanning
            cloud_connector - Edge(color=color_non_important) - s3_config
            cloud_connector >> Edge(color=color_non_important) >> cloudwatch
            cloud_scanning  >>  Edge(color=color_non_important) >> cloudwatch
            cloud_scanning >> codebuild
            codebuild >> Edge(color=color_non_important) >>  ecr


        member_accounts >> Edge(color=color_event, style="dashed") >>  cloudtrail
        sns >> Edge(color=color_event, style="dashed") >> sqs
#        cloudtrail_s3 << Edge(color=color_non_important) << cloud_connector
#        cloudtrail_s3 << Edge(color=color_non_important) << cloud_scanning
#        secure_for_cloud_role <<  Edge(color=color_permission, fontcolor=color_permission, xlabel="assumeRole") << cloud_connector
#        (cloudtrail_s3 << Edge(color=color_event) <<



    with Cluster("AWS account (sysdig)"):
        sds = Custom("Sysdig Secure", "../../resources/diag-sysdig-icon.png")


    cloud_connector >> Edge(color=color_sysdig) >> sds
    codebuild >> Edge(color=color_sysdig) >>  sds

#    secure_for_cloud_role >> Edge(color=color_permission, fontcolor=color_permission, xlable="assumeRole") >>  org_member_role_1


#    cloudtrail_legend  = ("to simplify,\l- events received from 'secure for cloud' member account  and management account have been removed from diagram, but will be processed too")
#    Node(label=cloudtrail_legend, shape="plaintext", labelloc="t", width="10", fontsize="10" )
