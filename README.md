## Requirements

- Terraform >= v1.11
- AWS cli configured
- kubectl
- python3

## Creating a cluster

Run the command below and follow the instructions.

```
curl -OLs https://github.com/getupcloud/getup-cluster-eks/raw/main/create-cluster.sh
bash ./create-cluster.sh
```

## Install gitleak to prevent any secret to be commited to local repo

Download `gitleaks` from https://github.com/gitleaks/gitleaks/releases/tag/v8.26.0 and put in your $PATH:

```
curl -L https://github.com/gitleaks/gitleaks/releases/download/v8.26.0/gitleaks_8.26.0_linux_x64.tar.gz \
  | tar xzvf - gitleaks
sudo mv gitleaks /usr/local/bin
```

Add it to your local repo's pre-commit hook:

```
mv bin/pre-commit > .git/hooks/pre-commit
git config hooks.gitleaks true
```

To ignore specific files from being reported as leaks, and the filename under `path` in file `.gitleaks.toml`.

You can also run it with the following command to scan the local dir and git repo:

```
gitleaks dir --redact=75 --max-decode-depth 5 --no-banner
gitleaks git --redact=75 --max-decode-depth 5 --no-banner
```

## Create terraform state bucket

If you do not already have a bucket to store terraform state, create one using the command below:

```
BUCKET_NAME="${CUSTOMER_NAME}-${CLUSTER_NAME}-terraform-state-$(date '+%Y%m%d')"
aws s3api create-bucket --bucket $BUCKET_NAME --region ${AWS_REGION}
```

## Setup terraform state backend

Copy the file `versions.tf.example` as `versions.tf`.

```
cp -i versions.tf.example versions.tf
```

Open it and fill the values:

```tf
terraform {
  ...

  backend "s3" {
    bucket = "${BUCKET_NAME}"                         ## the bucket name
    key    = "${CLUSTER_NAME}/terraform.tfstate"      ## path to store state file
    region = "$(AWS_REGION}"                          ## aws bucket region
  }

  ...
}
```

## Creating a cluster using existing VPC

### Enable public ipv4 on all **public** subnets

```
aws ec2 modify-subnet-attribute --subnet-id ${PUBLIC_SUBNET_ID} --map-public-ip-on-launch
```

### Create the service linked role for spot instances

```
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true
```

### Create user admin `${CLUSTER_NAME}-admin` with attached `AdministratorAccess` policy

```
aws iam create-user --user-name ${CLUSTER_NAME}-admin
aws iam attach-user-policy --user-name ${CLUSTER_NAME}-admin --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam create-access-key --user-name ${CLUSTER_NAME}-admin
```


## Configuring modules

All top-level modules are comprised of the following files:

- `main-${MODULE_NAME}.tf` - The main terraform module. Usually there is only this file with resources/modules;
- `variables-${MODULE_NAME}.tf` - Variables accepted by this module;
- `terraform-${MODULE_NAME}.auto.tfvars.example` - Example tfvars file. Simply copy it removing the `.example` suffix and edit it;
- `outputs-${MODULE_NAME}.tf` - Outputs of this module;
- `moved-${MODULE_NAME}.tf` - Declares `moved` statements for when resources have their names changed. Not all modules have one.

If you are not going to use a specific module, just remove its files.
For exemplo, to remove istio from your stack, execute:

```
$ rm *-istio-*
```
After removing, comment or remove the corresponding entry its `modules.yaml`:

```
$ cat modules.yaml
modules:
- argocd
- cert-manager
- ecr-credentials-sync
- eks
- external-secrets-operator
- external-dns
- flux
#- istio              ## Istio will be ignored
- loki
- opencost
- rds
- tempo
- velero
- vpc_peering
```

In the near future, we will handle this in a more automatic way.


## Main Commands

```
make pull       # pull from git origin
make init       # initializes terraform and validates soource code
make plan       # creates terraform plan on disk
make apply      # applies terraform plan from disk
make overlay    # populates tags `#output:{VAR_NAME}` in ./cluster/overlay/ using values from terraform outputs and tfvars[overlay]
make commit     # create local commit
make push       # push to git origin
```

## Support Commands

```
make help                # print help
make reconcile           # run simple reconcile: clean-output plan apply overlay commit push
make full-reconcile      # run full reconcile: clean-output pull init validate plan apply kubeconfig overlay commit push
make fmt                 # run terraform fmt
make upgrade             # run terraform init --upgrade 
make validate            # run terraform validate 
make kubeconfig          # download the kubeconfig file for kubectl
make output              # run terraform output
make destroy             # destroy kubernetes cluster resources and EKS
make update-version      # update modules versions from remote modules
make show-overlay-vars   # print all overlay vars from ./cluster/overlay
make kustomize|ks        # run kustomize in ./cluster
```
