# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Cluster, Diagram, Edge, Node
from diagrams.aws.compute import ElasticContainerServiceService, ECR
from diagrams.aws.devtools import Codebuild
from diagrams.aws.general import General
from diagrams.aws.integration import SNS, SQS
from diagrams.aws.management import Cloudtrail, Cloudwatch, CloudformationStack
from diagrams.aws.security import IAM, IAMRole
from diagrams.aws.storage import S3
from diagrams.custom import Custom

diagram_attr = {
    "pad":"0.75"
}

role_attr = {
   "imagescale":"true",
   "width":"2",
   "fontsize":"13",
}


color_event="firebrick"
color_scanning = "dark-green"
color_permission="steelblue3"
color_creates="gray"
color_non_important="gray"
color_sds="steelblue3"
color_managed="#E9E5F3"
color_others="#E0EDF4"
color_sysdig="#F3F3F3"




with Diagram("Sysdig Secure for Cloud\n(organizational)", graph_attr=diagram_attr, filename="diagram-org", show=True):

    public_registries = Custom("Public Registries","../../resources/diag-registry-icon.png")

    with Cluster("AWS Organization"):

        with Cluster("organiztional management account", graph_attr={"bgcolor":color_managed}):

            with Cluster("Events"):
                cloudtrail              = Cloudtrail("cloudtrail\n* ingest events from all\norg member accounts+managed", shape="plaintext")
                cloudtrail_s3           = S3("cloudtrail-s3-events")
                sns                     = SNS("cloudtrail-sns-events", comment="i'm a graph")

            management_credentials  = IAM("credentials \npermissions: cloudtrail, role creation,...")
            secure_for_cloud_role   = IAMRole("SysdigSecureForCloudRole\n\(enabled to assumeRole on \n`OrganizationAccountAccessRole`)", **role_attr)


            cloudtrail >> Edge(color=color_event, style="dashed") >> cloudtrail_s3 >> Edge(color=color_event, style="dashed") >> sns
            # cloudtrail_s3 >> Edge(style="invis") >> cft_stack_set

            with Cluster("CFT StackSet Instance"):
                cft_stack_3 = CloudformationStack("cloudformation-stack")
                cloud_bench_role_3 = IAMRole("SysdigCloudBench\n(aws:SecurityAudit policy)", **role_attr)
                cft_stack_3 >> Edge(color=color_creates) >> cloud_bench_role_3

            cft_stack_set  = CloudformationStack("cloudformation-stackset")
            cft_stack_set >> Edge(style="invis") >> cft_stack_3
            management_credentials >> Edge(style="invis") >> cft_stack_3


        with Cluster("organizational member account - rest of accounts", graph_attr={"bgcolor":color_sysdig, "margin":"0,50px"}):
            ecr = ECR("container-registry\n*sends events on image push to cloudtrail\n*within any account")

            with Cluster("ecs services - others"):
                ecs_services = ElasticContainerServiceService("other services\n*sends events with image runs to cloudtrail")


            with Cluster("CFT StackSet Instance"):
                cft_stack = CloudformationStack("cloudformation-stack")
                cloud_bench_role = IAMRole("SysdigCloudBench\n(aws:SecurityAudit policy)", **role_attr)
                cft_stack >> Edge(color=color_creates) >> cloud_bench_role

            org_member_role_1 = IAMRole("OrganizationAccountAccessRole\n(created by AWS for org. \nmember accounts)", **role_attr)

            #ecr >> Edge(style="invis") >> ecs_services


        with Cluster("organizational member account - sysdig workload", graph_attr={"bgcolor":color_others}):

            org_member_role_2 = IAMRole("OrganizationAccountAccessRole\n(created by AWS for org. \nmember accounts)", **role_attr)

            sqs         = SQS("cloudtrail-sqs")
            s3_config   = S3("cloud-connector-config")
            cloudwatch  = Cloudwatch("cloudwatch\nlogs and alarms")
            codebuild   = Codebuild("codebuild project")

            with Cluster("CFT StackSet Instance"):
                cft_stack_2 = CloudformationStack("cloudformation-stack")
                cloud_bench_role_2 = IAMRole("SysdigCloudBench\n(aws:SecurityAudit policy)", **role_attr)
                cft_stack_2 >> Edge(color=color_creates) >> cloud_bench_role_2

            with Cluster("ecs-cluster"):
                cloud_connector = ElasticContainerServiceService("cloud-connector")

            sqs << Edge(color=color_event) << cloud_connector
            cloud_connector - Edge(color=color_non_important) - s3_config
            cloud_connector >> Edge(color=color_non_important) >> cloudwatch
            cloud_connector  >>  Edge(color=color_non_important) >> cloudwatch
            cloud_connector >> codebuild
            codebuild >> Edge(color=color_non_important) >>  ecr
            codebuild >> Edge(color=color_non_important) >>  public_registries

            org_member_role_2 >> Edge(style="invis") >> cft_stack_2


        sns >> Edge(color=color_event, style="dashed") >> sqs
#        cloudtrail_s3 << Edge(color=color_non_important) << cloud_connector
#        cloudtrail_s3 << Edge(color=color_non_important) << cloud_scanning
#        secure_for_cloud_role <<  Edge(color=color_permission, fontcolor=color_permission, xlabel="assumeRole") << cloud_connector
#        (cloudtrail_s3 << Edge(color=color_event) <<


        cft_stack_set >> Edge(color=color_creates) >> cft_stack
        cft_stack_set >> Edge(color=color_creates) >> cft_stack_2
        cft_stack_set >> Edge(color=color_creates) >> cft_stack_3



    with Cluster("AWS account (sysdig)"):
        sds = Custom("Sysdig Secure\n*receives cloud-connector and cloud-build results\n*assumeRole on SysdigCloudBench", "../../resources/diag-sysdig-icon.png")
        sds_account = General("cloud-bench")
        sds - Edge(label="aws_foundations_bench\n schedule on rand rand * * *") >>  sds_account

    cloud_connector >> Edge(color=color_sds) >> sds
    codebuild >> Edge(color=color_sds) >>  sds

    sds_account >> Edge(color=color_permission) >> cloud_bench_role
    sds_account >> Edge(color=color_permission) >> cloud_bench_role_2
    sds_account >> Edge(color=color_permission) >> cloud_bench_role_3

    # Invisible edges to help with layout
    sns >> Edge(style="invis") >> org_member_role_2

#    secure_for_cloud_role >> Edge(color=color_permission, fontcolor=color_permission, xlable="assumeRole") >>  org_member_role_1


#    cloudtrail_legend  = ("to simplify,\l- events received from 'secure for cloud' member account  and management account have been removed from diagram, but will be processed too")
#    Node(label=cloudtrail_legend, shape="plaintext", labelloc="t", width="10", fontsize="10" )
