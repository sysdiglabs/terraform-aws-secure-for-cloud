# DecisionRecord

> A [Decision record (DR)](https://github.com/joelparkerhenderson/decision-record) is a way to initiate, debate, and archive an important choice, along with its context and consequences.

Some ideas that would fit in the DR
- global refactorings
- current known limitations
- ...

**Note: Currently, this DR apply to all Terraform Modules (AWS,GCP and Azure)**

<br/>

## 2022 - Remove configuration buckets

Previously [CloudConnector configuration file](https://charts.sysdig.com/charts/cloud-connector/#configuration) was stored on each cloud storage service.
In order to spin as least resources as possible on customer's infra, we decided to inline this configuration with a base64-encoded `env` var.

- pros
  - less resources on customer
- cons
  - modifying configuration (the most common use-case is to lower logs for troubleshooting purpose) is more complicated for the customer


## 2021 - Terraform Modules version pinned to `latest`

Because we're in fast cycle-releases (v0.x), we don't support backward compatibility and want customer to use latest version.
That's why in Github snippets, and Sysig Secure snippets, we don't use the `version` attirubte of the terraform modules.

Still, customer wants to pin the terraform module version, they can do so, by using

```terraform
module "secure-for-cloud" {
  source  = "sysdiglabs/secure-for-cloud/aws"
  version = "0.9.6"
  ...
}
```

Upgrade guideliness are offered in main READMEs.


## 2021 - CloudConnector image version pinned to `latest`

Not discussed the pro/cons, but currently

- pros
  -  if we fix somethiing in cloud-connector customer just has to restart the compute service
- cons
  - if required, there is no easy way of pinning the cloud-connector version

**Possible future actions**
- Expose a variable throught he examples to let customer select cloud-connector version? This can also be done in runtime modifying compute service defintion.
