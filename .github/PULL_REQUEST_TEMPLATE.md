> PR template
>
> * for a cleaner PR, **delete whatever is not required**
> * use pull-request **drafts for visibility on WIP branches**
> * unless a revision is desired in order to validate, or gather some feedback, **you are free to merge it as long as**
>   * validation checkers are all green-lighted
>   * pre-merge checklist has been reviewed. for more detail check **`/CONTRIBUTE.md`**

-  [ ] **modules** (infra or services) have been modified?
    - [ ] a `README.md` has been added
    - [ ] if modules are relevant to usage-case understanding `diagram.py/png` have been updated accodingly
    - [ ] if prerequirements have been modified, update accordingly on
      - [ ] README's
      - [ ] Sysdig docs
- [ ] **input/output** variables have been modified?
  - [ ] terraform-docs has been updated acordingly
  - [ ] if these inputs are mandatory, they've been changed on
      - [ ] examples
      - [ ] testing use-cases
      - [ ] snippets on README's
      - [ ] snippets on Secure Platform onboarding
- [ ] had any problems developing this PR? add it to the readme **troubleshooting** list! may come handy to someone
