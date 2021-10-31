## usage

- populate `.envrc.template` > `.envrc`
- connect to eks
    ```
    aws eks --region $(terraform output -raw k8s_region) update-kubeconfig --name $(terraform output -raw k8s_name)
    ```
