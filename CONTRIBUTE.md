# General

- Use **conventional commits** | https://www.conventionalcommits.org/en/v1.0.0
  - Current suggested **scopes** to be used within feat(scope), fix(scope), ...
    - threat
    - bench
    - scan
    - docs
- Maintain example **diagrams** for a better understanding of the architecture and sysdig secure resources
  - example diagram-as-code | https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account/diagram-single.py
  - resulting diagram | https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account/diagram-single.png
- Utilities
  - Useful Terraform development guides | https://www.terraform-best-practices.com



# Pull Request

- Terraform **lint** and **validation is enforced vía pre-commit** |  https://pre-commit.com
  - custom configuration | https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/.pre-commit-config.yaml
  - current `terraform-docs` requires developer to create `README.md` file, with the enclosure tags for docs to insert the automated content
  ```markdown
  <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
  <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
  ```
- Kitchen tests | https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/test/integration/kt_suite


# Release

- Use **semver** for releases https://semver.org
- Module official releases will be published at terraform registry
- Just create a tag/release and it will be  fetched by pre-configured webhook and published into.
  - For internal usage, TAGs can be used
  - For officual verions, RELEASEs will be used, with its corresponding changelog description.
