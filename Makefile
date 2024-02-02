#
# You can use this Makefile to create resources using the modules from this repo.
# This is a suggestion, not a requirement.
#

TERRAFORM    ?= terraform
TF_LOG_PATH  ?= terraform.log
TF_LOG       ?= DEBUG
CLUSTER_NAME ?= $(shell sed -ne 's|^\s*cluster_name\s*=\s*"\([^"]\+\)"|\1|p' terraform.tfvars 2>/dev/null)
LOCAL_IPS    ?= ["$(shell curl -s https://api.ipify.org)/32"]
# TODO: Ler grupo usando terraform e injetar no configmap/aws-auth
# AWS_AUTH_GROUP_NAME := Infra
# AWS_AUTH_USER_ARNS ?= $(shell aws iam get-group --group-name $(AWS_AUTH_GROUP_NAME) | jq -cr '[.Users[].Arn]')

.ONESHELL:
.EXPORT_ALL_VARIABLES:

all:
	@echo 'Usage: make [init|validate|fmt|plan|apply|output|kubeconfig]'

clean:
	rm -rf .terraform terraform.log

init: validate-vars
	$(TERRAFORM) init $(TERRAFORM_ARGS) $(TERRAFORM_INIT_ARGS)

validate: validate-vars
	$(TERRAFORM) validate $(TERRAFORM_ARGS) $(TERRAFORM_VALIDATE_ARGS)

fmt:
	$(TERRAFORM) fmt $(TERRAFORM_ARGS) $(TERRAFORM_FMT_ARGS)

plan: validate-vars
	$(TERRAFORM) plan -out terraform.tfplan \
		-var cluster_name=$(CLUSTER_NAME) \
		-var cluster_endpoint_public_access_cidrs='$(LOCAL_IPS)' \
		$(TERRAFORM_ARGS) $(TERRAFORM_PLAN_ARGS)

# WARNING: NOT CONFIRMATION ON APPLY
apply:
	$(TERRAFORM) apply -auto-approve terraform.tfplan $(TERRAFORM_ARGS) $(TERRAFORM_APPLY_ARGS)

# WARNING: NOT CONFIRMATION ON DESTROY
destroy:
	$(TERRAFORM) destroy -auto-approve $(TERRAFORM_ARGS) $(TERRAFORM_DESTROY_ARGS)

output:
	$(TERRAFORM) output -json $(TERRAFORM_ARGS) $(TERRAFORM_OUTPUT_ARGS)

kubeconfig:
	aws eks update-kubeconfig --name=$(CLUSTER_NAME) $(AWS_EKS_ARGS)

###

validate-vars:
	@if [ -z "$(CLUSTER_NAME)" ]; then
		echo "Missing required var: CLUSTER_NAME"
		exit 1
	fi
