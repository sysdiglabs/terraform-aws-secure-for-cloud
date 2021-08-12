#!/bin/bash

for dir in examples/*
do
  echo validating example [$dir]
  cd $dir
  terraform validate
  cd ..
done
