#!/bin/bash

COLOR_BOLD=$(tput bold)
COLOR_ON="$(tput setaf 3)${COLOR_BOLD}"
COLOR_OFF=$(tput sgr0)

set -ue

read -p "${COLOR_ON}-> Customer name:${COLOR_OFF} " CUSTOMER_NAME
read -p "${COLOR_ON}-> Cluster name:${COLOR_OFF} " CLUSTER_NAME

repo="customer-$CUSTOMER_NAME-$CLUSTER_NAME"

if [ -d "$repo" ]; then
  echo "Error: Directory exists: $repo"
  exit 1
fi

git clone git@github.com:getupcloud/getup-cluster-doks.git $repo
cd $repo

git remote remove origin

if [ -v GITHUB_TOKEN ]; then
  echo Using environment variable GITHUB_TOKEN to authenticate to Github.
elif ! gh auth status 2>/dev/null; then
  if ! gh auth login; then
    echo Github login failed
    exit 1
  fi
fi

gh org list
read -e -p "${COLOR_ON}-> Type org name to create the new repository:${COLOR_OFF} " org

gh repo create $org/$repo \
  --source=./ \
  --private=true \
  --description="Kubernetes cluster $CLUSTER_NAME for $CUSTOMER_NAME" \
  --disable-issues=true \
  --disable-wiki=true

echo Pushing to remote for the first time: git@github.com:$org/$repo
git remote set-url origin git@github.com:$org/$repo
git push origin main

teams=( $(gh api /orgs/${org}/teams | jq -r '.[]|.slug') )

if [ ${#teams[*]} -gt 0 ]; then
  echo Showing teams
  echo
  printf "%s\n" ${teams[*]}
  read -e -p "${COLOR_ON}-> Type space-separated team names to give admin permisssions to:${COLOR_OFF} " team_names

  if [ -n "$team_names" ]; then
    for team in $team_names; do
      gh api /orgs/${org}/teams/${team}/repos/$org/$repo \
        --method PUT \
        -H "Accept: application/vnd.github.v3+json" \
        -f permission=admin
    done
  fi
fi

echo
echo "${COLOR_ON}Edit and/or remove unnecessary terraform files:${COLOR_OFF}"
ls -1 *.tf | sort | sed -e 's/^/- /'
echo
echo "${COLOR_ON}Rename required *.tfvars.example files to .tfvar:${COLOR_OFF}"
ls -1 *tfvar* | sort | sed -e 's/^/- /'

echo
echo "# You can now"
echo "${COLOR_BOLD}cd ./$repo${COLOR_OFF}"
echo
echo "# Edit the files and run"
echo "$COLOR_BOLD"
echo make init
echo make validate
echo make plan
echo make apply
echo make overlay
echo make commit
echo make push
echo "$COLOR_OFF"
