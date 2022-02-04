#!/bin/bash

cd ..
find . -name ".terraform" -exec rm -fr {} \;
find . -name "terraform.tfstate*" -exec rm -fr {} \;
find . -name ".terraform.lock.hcl*" -exec rm -fr {} \;
