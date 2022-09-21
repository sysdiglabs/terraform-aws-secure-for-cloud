<!--
Thank you for your contribution!

## Testing your PR

You can pinpoint the pr changes as terraform module source with following format 

```
source                    = "github.com/sysdiglabs/terraform-aws-secure-for-cloud//examples/organizational?ref=<BRANCH_NAME>" 
```


## General recommendations
Check contribution guidelines at https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/CONTRIBUTE.md#contribution-checklist

For a cleaner PR make sure you follow these recommendations:
- Review modified files and delete small changes that were not intended and maybe slip the commit.
- Use Pull Request Drafts for visibility on Work-In-Progress branches and use them on daily mob/pairing for team review
- Unless an external revision is desired, in order to validate or gather some feedback, you are free to merge as long as **validation checks are green-lighted**

## Checklist

- [ ] If `test/fixtures/*/main.tf` files are modified, update:
    - [ ] the snippets in the README.md file under root folder.
    - [ ] the snippets in the README.md file for the corresponding example.
- [ ] If `examples` folder are modified, update:
    - [ ] README.md file with pertinent changes.
    - [ ] `test/fixtures/*/main.tf` in case the snippet needs modifications.
- [ ] If any architectural change has been made, update the diagrams.

-->
