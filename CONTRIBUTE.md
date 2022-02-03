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
  - [ ] if modules are relevant to usage-case understanding `diagram.py/png` have been updated accodingly
  - [ ] if pre-requirements have been modified, update accordingly on
    - [ ] README's
    - [ ] Sysdig docs
- [ ] **input/output** variables have been modified?
  - [ ] terraform-docs has been updated accordingly
  - [ ] if these inputs are mandatory, they've been changed on
    - [ ] examples
    - [ ] testing use-cases
    - [ ] snippets on README's
    - [ ] snippets on Secure Platform onboarding
- [ ] had any problems developing this PR? add it to the readme **troubleshooting** list! may come handy to someone


## 1. Check::Pre-Commit

Technical validation for terraform **lint**, **validation**, and **documentation**

We're using **pre-commit** |  https://pre-commit.com
- Defined in `/.pre-commit-config.yaml`
- custom configuration | https://github.com/sysdiglabs/terraform-google-secure-for-cloud/blob/master/.pre-commit-config.yaml
- current `terraform-docs` version, requires developer to create `README.md` file, with the enclosure tags for docs to insert the automated content
  ```markdown
  <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
  <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
  ```

- If pre-commit fails on Github but not on your local, please cleanup `terraform` files with
```bash
$ find . -name ".terraform" -exec rm -fr {} \;
$ find . -name "terraform.tfstate*" -exec rm -fr {} \;
$ find . -name ".terraform.lock.hcl*" -exec rm -fr {} \;
```


## 2. Check::Integration tests

Final user validation. Checks that the snippets for the usage, stated in the official Sysdig Terraform Registry, are working correctly.

Implemented vía **Terraform Kitchen** | https://newcontext-oss.github.io/kitchen-terraform

### Kitchen

- Kitchen configuration can be found in `/.kitchen.yml`
- Under `/test/fixtures` you can find the targets that will be tested. Please keep this as similar as possible to the Terraform Registry Modules examples.
- AWS_PROFILE configuration is required to access the [TF s3 state backend](#terraform-backend)

**Running Kitchen tests locally**

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

### Terraform Backend

Because CI/CD sometimes fail, we setup the Terraform state to be handled in backend (s3+dynamo) within the Sysdig AWS backend (sysdig-test-account).
In order to be able to use this Terraform backend AWS credentials are configured as Github project secret

If terraform state ends up in bad shape and not cleaned, use the action called `Test Cleanup` that should destroy any messed situation.
If this does not work, try it from your local, but please do it using `kitchen destroy`, not `terraform destroy` unless you really know what you're doing :]

### Deployed infrastructure resources

Check project github secrets for clarification

# Release

Feel free to release as soon as needed.

- Create a tag and it will be  fetched by pre-configured webhook.
  - use [semver](https://semver.org) notation
- A changelog description will be generated based on [conventional-commints](https://www.conventionalcommits.org/en/v1.0.0/) , but please verify all changes are included and explain acordingly if/when required
- Module official releases will be published at terraform registry automatically
