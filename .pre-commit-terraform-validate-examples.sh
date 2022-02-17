#!/bin/bash

# ensure errexit + failfast
set -o errexit

# cleanup
bash ./resources/terraform-clean.sh

for dir in examples*/*
do

  # skip aliased providers due to terraform validate unresolved bug
  # https://github.com/hashicorp/terraform/issues/28490
  if [ $dir == "examples/organizational" ]; then
    echo "skipping validation on [$dir]"
    break
  fi
  echo validating example [$dir]
  cd $dir
  terraform init
  terraform validate
  cd ../..
done
