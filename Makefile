deps:
	go install github.com/terraform-docs/terraform-docs@v0.16.0
	go install github.com/hashicorp/terraform-config-inspect@latest
	curl -L "`curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip"`" -o tflint.zip && \
		unzip tflint.zip && \
		rm tflint.zip && \
		mv tflint "`go env GOPATH`/bin"

clean:
	find -name ".terraform" -type d | xargs rm -rf
	find -name ".terraform.lock.hcl" -type f | xargs rm -f

# https://github.com/antonbabenko/pre-commit-terraform/#terraform_validate
# Adding this patch to fix organizational multi-provider terraform validate error
# 'missing provider provider["registry.terraform.io/hashicorp/google"].multiproject'
generate-terraform-providers:
	./resources/scripts/generate_providers.sh ./modules/infrastructure/permissions/org-role-ecs ./examples/organizational

terraform-init: generate-terraform-providers
	find -name "*.tf" | xargs dirname | uniq | xargs -I% -P0 sh -c 'cd %; terraform init --backend=false' 1>/dev/null

docs: clean generate-terraform-providers
	pre-commit run -a terraform_docs

lint: terraform-init
	pre-commit run -a terraform_validate
	pre-commit run -a terraform_tflint

fmt:
	find -name "*.tf" | xargs dirname | uniq | xargs -I% -P0 sh -c 'cd %; terraform fmt'
	pre-commit run -a terraform_fmt
