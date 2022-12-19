# General

- Use **conventional commits** | https://www.conventionalcommits.org/en/v1.0.0
  - Current suggested **scopes** to be used within feat(scope), fix(scope), ...
    - threat
    - bench
    - scan
    - docs
    - tests
- Maintain example **diagrams** for a better understanding of the architecture and Sysdig secure resources
  - example diagram-as-code (check for `diagram.py` within the examples)
  - resulting diagram (check for `diagram.png` within the examples)
- Utilities
  - Useful Terraform development guides | https://www.terraform-best-practices.com


# Pull Request

> TL;DR;<br/>
> Feel free to merge as soon as needed, provided pre-merge checks pass<br/>
> Should any fail, check `/.github/workflows/ci-integration-test.yaml` to identify what's required

## 0. General Guidelines

* Use pull-request **drafts for visibility on WIP branches**
* Unless a revision is desired in order to validate, or gather some feedback, **you are free to merge it as long as**
  * validation checkers are all green-lighted
  * you've got permissions to do so :)
* Check whether anything else is required for your contribution

### Contribution checklist

-  [ ] **modules** (infra or services) have been modified?
  - [ ] a `README.md` file has been added to the folder
  - [ ] if modules are relevant to usage-case understanding `diagram.py/png` have been updated accordingly. To re-generate diagrams yo need to run `python diagram.py` and need diagram installed `pip install diagrams`.
  - [ ] if pre-requirements have been modified, update accordingly on
    - [ ] README's
    - [ ] Sysdig docs
- [ ] **input/output** variables have been modified?
  - [ ] terraform-docs has been updated accordingly
  - [ ] if these inputs are mandatory, they've been changed on
    - [ ] examples, examples-internal and use-cases are updated accordingly
    - [ ] tests are updated accordingly
    - [ ] snippets on README's are updated accordingly
    - [ ] snippets on Secure Platform onboarding are updated accordingly
- [ ] had any problems developing this PR? add it to the readme **troubleshooting** list! may come handy to someone


## 1. Check::Pre-Commit

Technical validation for terraform **lint**, **validation**, **documentation** and **security scan**.

We're using **pre-commit** |  https://pre-commit.com
- Defined in `/.pre-commit-config.yaml`
- custom configuration | https://github.com/sysdiglabs/terraform-google-secure-for-cloud/blob/master/.pre-commit-config.yaml
- current `terraform-docs` version, requires developer to create `README.md` file, with the enclosure tags for docs to insert the automated content
  ```markdown
  <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
  <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
  ```
- pre-requirement download, for [terrascan](https://github.com/tenable/terrascan#step-1-install)

## 2. Check::Integration tests

Final user validation. Checks that the snippets for the usage, stated in the official Sysdig Terraform Registry, are working correctly.

Implemented vía **Terraform Kitchen** | https://newcontext-oss.github.io/kitchen-terraform

### Kitchen

- Kitchen configuration can be found in `/.kitchen.yml`
- Under `/test/fixtures` you can find the targets that will be tested. Please keep this as similar as possible to the Terraform Registry Modules examples.
  - In order to test this in your local environment use following recipee
  ```bash
  terraform init -backend=false && \
  terraform validate && \
  terraform plan && \
  read && \   # will give you time to review plan or just push enter to apply
  terraform apply --auto-approve
  ```
- AWS_PROFILE configuration is required to access the [TF s3 state backend](#terraform-backend)

### Terraform Backend

Because CI/CD sometimes fail, we setup the Terraform state to be handled in backend (s3+dynamo) within the Sysdig AWS backend (sysdig-test-account).

#### Remote state cleanup from local

In case you need to handle terraform backend state from failing kitchen tests, some guidance for using the `backend.tf` remote state manifest, present on each test
 - Configure same parameters as the github action, that is `AWS_PROFILE`, and leave default `name` and `region` values
 - Kitchen works with `terraform workspaces` so, in case you want to fix a specific test, switch to that workspace after the `terraform init` with `terraform workspace select WORKSPACE`
 - Perform the desired terraform task

You can also use `kitchen destroy` instead of `terraform` but the requirements are the same, except that the workspace will be managed through kitchen

#### State unlock
```
# go to the specific test ex.:
cd test/fixtures/single-subscription

# unlock kitchetn state
terraform init
terraform workspace list
terraform workspace select kitchen-terraform-WORKSPACE_NAME
terraform force-unlock LOCK_ID
```


### Running Kitchen tests locally

Ruby 2.7 is required to launch the tests.
Run `bundle install` to get kitchen-terraform bundle.
Cloud Provider credentials should be configured locally.
```shell
# launch all the tests, in other words, it will run `terraform apply`
$ bundle exec kitchen converge

# will destroy test infrastructure, in short, it will run `terraform destroy`
$ bundle exec kitchen destroy

# run all the workflow. In first place, it will run an `apply`. Then, if and only if the `apply` works it will destroy the infrastructure.
$ bundle exec kitchen tests

# run one specific test
$ bundle exec kitchen test "single-account-k8s-aws"
```

Note: As said before kitchen works with workspaces, so any local test, unless you change it, will fall into the `default` workspace and will not collide with
Github Action tests. May collide however with other peers if they're doing similar tasks on local ;)
You can always temporary delete the `backend.tf` file on the test you're running

### Deployed infrastructure resources

Check project github secrets for clarification

# Release

Feel free to release as soon as needed.

- Create a tag and it will be  fetched by pre-configured webhook.
  - use [semver](https://semver.org) notation
- A changelog description will be generated based on [conventional-commints](https://www.conventionalcommits.org/en/v1.0.0/) , but please verify all changes are included and explain acordingly if/when required
- Module official releases will be published at terraform registry automatically


---


### How to iterate cloud-connector modification testing

Build a custom docker image of cloud-connector `docker build . -t <DOCKER_IMAGE> -f ./build/cloud-connector/Dockerfile` and upload it to any registry (like dockerhub).
Modify the [var.image](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-connector/variables.tf) variable to point to your image and deploy

### How can I iterate ECS modification testing

After applying your modifications (vía terraform for example) restart the service
  ```
  $ aws ecs update-service --force-new-deployment --cluster sysdig-secure-for-cloud-ecscluster --service sysdig-secure-for-cloud-cloudconnector --profile <AWS_PROFILE>
  ```
For the AWS_PROFILE, set your `~/.aws/config` to impersonate
  ```
  [profile secure-for-cloud]
  region=eu-central-1
  role_arn=arn:aws:iam::<AWS_MANAGEMENT_ORGANIZATION_ACCOUNT>:role/OrganizationAccountAccessRole
  source_profile=<AWS_MANAGEMENT_ACCOUNT_PROFILE>
  ```
