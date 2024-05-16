#
# You can use this Makefile to create resources using the modules from this repo.
# This is a suggestion, not a requirement.
#

TERRAFORM      ?= terraform
TF_LOG_PATH    ?= terraform.log
TF_LOG         ?= DEBUG
CLUSTER_NAME   ?= $(shell sed -ne 's|^\s*cluster_name\s*=\s*"\([^"]\+\)"|\1|p' *.tfvars 2>/dev/null)

ifeq ($(AUTO_LOCAL_IP),true)
  TERRAFORM_ARGS += -var cluster_endpoint_public_access_cidrs='["$(shell curl -s https://api.ipify.org)/32"]'
endif

KUSTOMIZE_BUILD := .kustomize_build.yaml

# TODO: Ler grupo usando terraform e injetar no configmap/aws-auth
# AWS_AUTH_GROUP_NAME := Infra
# AWS_AUTH_USER_ARNS ?= $(shell aws iam get-group --group-name $(AWS_AUTH_GROUP_NAME) | jq -cr '[.Users[].Arn]')

.ONESHELL:
.EXPORT_ALL_VARIABLES:

all help:
	@echo Targets:
	echo
	printf -- "- %s\n" init validate fmt plan apply overaly output kubeconfig update-version update-source clean destroy

clean:
	rm -rf .terraform terraform.log $(KUSTOMIZE_BUILD)

init: validate-vars
	$(TERRAFORM) init $(TERRAFORM_ARGS) $(TERRAFORM_INIT_ARGS)

upgrade: validate-vars
	$(TERRAFORM) init -upgrade $(TERRAFORM_ARGS) $(TERRAFORM_INIT_ARGS)

validate: validate-vars
	$(TERRAFORM) validate $(TERRAFORM_ARGS) $(TERRAFORM_VALIDATE_ARGS)

fmt:
	$(TERRAFORM) fmt $(TERRAFORM_ARGS) $(TERRAFORM_FMT_ARGS)

plan: validate-vars
	$(TERRAFORM) plan -out terraform.tfplan $(TERRAFORM_ARGS) $(TERRAFORM_PLAN_ARGS)

# WARNING: NO CONFIRMATION ON APPLY
apply:
	$(TERRAFORM) apply -auto-approve terraform.tfplan $(TERRAFORM_ARGS) $(TERRAFORM_APPLY_ARGS)

destroy:
	$(TERRAFORM) destroy $(TERRAFORM_ARGS) $(TERRAFORM_DESTROY_ARGS)

# WARNING: NO CONFIRMATION ON DESTROY
destroy-auto-approve:
	$(TERRAFORM) destroy -auto-approve $(TERRAFORM_ARGS) $(TERRAFORM_DESTROY_ARGS)

output:
	$(TERRAFORM) output -json $(TERRAFORM_ARGS) $(TERRAFORM_OUTPUT_ARGS) > output.json

kubeconfig:
	aws eks update-kubeconfig --name=$(CLUSTER_NAME) $(AWS_EKS_ARGS)

update-version:
	latest=$$(timeout 3 curl -s https://raw.githubusercontent.com/getupcloud/terraform-modules/main/version.txt || echo 0.0.0)
	latest=$${latest}
	read -e -p "New module version: " -i "$$latest" v
	sed -i -e '/source/s/ref=v[0-9]\+\.[0-9]\+\.[0-9]\+/ref=v'$$v'/g' main-*tf

show-vars:
	grep -wrn -A 1 --color '#[a-zA-Z0-9_]\+#' cluster/overlay 2>/dev/null

kustomize ks:
	@echo Checking kustomization
	if ! kubectl kustomize ./cluster -o $(KUSTOMIZE_BUILD); then
		echo Generated output: $(KUSTOMIZE_BUILD)
		exit 1
	fi

overlay:
	@echo Generating output.json
	$(TERRAFORM) output -json $(TERRAFORM_ARGS) $(TERRAFORM_OUTPUT_ARGS) > output.json
	echo Generating overlays
	find cluster/overlay -type f | while read file; do
		echo $$file
		python bin/overlay.py output.json $$file >$${file}.tmp && mv $${file}.tmp $$file || exit 1
	done

validate-vars:
	@if [ -z "$(CLUSTER_NAME)" ]; then
		echo "Missing required var: CLUSTER_NAME"
		exit 1
	fi

update-source:
	cp ../terraform-modules/examples/*/{main,outputs,variables}-*.tf ../terraform-modules/examples/*/*.tfvars.example . -v
