## usage

```terraform
module "eks"{
  source = "sysdiglabs/secure-for-cloud/aws//modules/infrastructure/eks"
  default_vpc_subnets = ["<SUBNET_1>", "<SUBNET_2>"]
  name = "<IDENTIFYING_NAME>"
}

```

- connect to eks
```
  aws eks --region <REGION> update-kubeconfig --name <IDENTIFYING_NAME>
```

- kubectx; select the cluster and enjoy
