#!/bin/bash

# use from root path  ./resources/scripts/terraform-clean.sh
# we don't wanna delete possible ./test state tests

pushd .
cd examples
find . -name ".terraform" -exec rm -fr {} \;
find . -name "terraform.tfstate*" -exec rm -fr {} \;
find . -name ".terraform.lock.hcl*" -exec rm -fr {} \;

popd
cd modules
find . -name ".terraform" -exec rm -fr {} \;
find . -name "terraform.tfstate*" -exec rm -fr {} \;
find . -name ".terraform.lock.hcl*" -exec rm -fr {} \;
