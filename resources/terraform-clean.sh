#!/bin/bash

# we don't wanna delete possible ./test state tests

cd ../examples
find . -name ".terraform" -exec rm -fr {} \;
find . -name "terraform.tfstate*" -exec rm -fr {} \;
find . -name ".terraform.lock.hcl*" -exec rm -fr {} \;

cd ../modules
find . -name ".terraform" -exec rm -fr {} \;
find . -name "terraform.tfstate*" -exec rm -fr {} \;
find . -name ".terraform.lock.hcl*" -exec rm -fr {} \;
