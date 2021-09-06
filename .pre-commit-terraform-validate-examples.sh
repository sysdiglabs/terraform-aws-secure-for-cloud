#!/bin/bash

# ensure errexit + failfast
set -o errexit

for dir in examples*/*
do
  echo validating example [$dir]
  cd $dir
  terraform init
  terraform validate
  cd ../..
done
