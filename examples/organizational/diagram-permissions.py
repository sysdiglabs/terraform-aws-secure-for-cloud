# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Cluster, Diagram, Edge, Node
from diagrams.aws.security import IAM, IAMRole
from diagrams.aws.management import Cloudtrail
from diagrams.aws.storage import S3
from diagrams.aws.compute import ECR


with Diagram("Sysdig Secure for Cloud\n(organizational permissions)", filename="diagram-permissions", show=True):


    with Cluster("member account (sysdig workload)"):
#        bench_role = IAMRole(label="Benchmark role")
        member_sysdig_role = IAMRole(label="OrganizationAccountAccessRole")
        member_sysdig_ecr = ECR("container registry")
        member_sysdig_role >> member_sysdig_ecr

        ecs_role = IAMRole(label="ECSTaskRole")
        # bench_role - Edge(style="invis") - member_sysdig_ecr


    with Cluster("member accounts"):
#        IAMRole(label="Benchmark role")

        member_role = IAMRole(label="OrganizationAccountAccessRole")
        member_ecr = ECR("container registry")
        member_role >> member_ecr


    with Cluster("management account"):
#        IAMRole(label="Benchmark role")
        sf4c_role = IAMRole(label="SysdigSecureForCloud")
        sf4c_role >> Cloudtrail()
        sf4c_role >> S3()


    ecs_role >> sf4c_role
    sf4c_role >> member_role
    sf4c_role >> member_sysdig_role
