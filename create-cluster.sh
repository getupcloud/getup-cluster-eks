#!/bin/bash

set -ue

read -p "Customer name: " CUSTOMER_NAME
read -p "Cluster name: " CLUSTER_NAME

repo="customer-$CUSTOMER_NAME-$CLUSTER_NAME"

git clone git@github.com:getupcloud/terraform-cluster.git $repo
cd $repo
git remote set-url origin git@github.com/getupcloud/${repo}.git
cd ..

echo
echo "$(tput setaf 3)$(tput bold)Edit and/or remove unnecessary terraform files:$(tput sgr0)"
ls -1 $repo/*.tf | sort | sed -e 's/^/- /'
echo
echo "$(tput setaf 3)$(tput bold)Rename required *.tfvars.example files to .tfvar:$(tput sgr0)"
ls -1 $repo/*tfvar* | sort | sed -e 's/^/- /'

echo
echo "# You can now"
tput bold
echo cd ./$repo
tput sgr0
echo "# Edit the files and run"
tput bold
echo make init
echo make validate
echo make plan
echo make apply
tput sgr0
