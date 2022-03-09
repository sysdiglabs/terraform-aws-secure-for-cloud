#!/bin/bash

# ensure errexit + failfast
set -o errexit

# cleanup
echo "cleaning .terraform state"
bash ./resources/terraform-clean.sh

for dir in $(find . -name 'versions.tf' -not -path '*.terraform*' -exec dirname {} \;)
do
  echo validating [$dir]
  # skip aliased providers due to terraform validate unresolved bug
  # https://github.com/hashicorp/terraform/issues/28490
  if [ "$dir" == "examples/organizational" ]; then
    echo "skipping validation on [$dir]"
    break
  fi
  pushd .
  cd "$dir"
  # force init
  # https://github.com/antonbabenko/pre-commit-terraform/issues/224
  terraform init --upgrade
  terraform validate
  popd
done
