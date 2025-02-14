## Requirements

- Terraform v1.7
- AWS cli configured
- kubectl
- python3

## Creating a cluster

Run the command below and follow the instructions.

```
curl -OLs https://github.com/getupcloud/terraform-cluster/raw/main/create-cluster.sh
bash ./create-cluster.sh
```

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
make pull                # run git pull
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
