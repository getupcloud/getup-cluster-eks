#
# You can use this Makefile to create resources using the modules from this repo.
# This is a suggestion, not a requirement.
#

TERRAFORM           ?= terraform
TF_LOG_PATH         ?= terraform.log
TF_LOG              ?= DEBUG
CUSTOMERNAME        ?= $(shell sed -ne 's|^\s*customer_name\s*=\s*"\([^"]\+\)"|\1|p' *.tfvars 2>/dev/null)
CLUSTER_NAME        ?= $(shell sed -ne 's|^\s*cluster_name\s*=\s*"\([^"]\+\)"|\1|p' *.tfvars 2>/dev/null)
GIT_REMOTE          ?= origin
GIT_BRANCH          ?= main
GIT_COMMIT_MESSAGE  ?= Auto-generated commit
FLOW_RECONCILE      := plan apply overlay commit push
FLOW_FULL_RECONCILE := pull init validate plan apply kubeconfig overlay commit push
KUSTOMIZE_BUILD     := .kustomize_build.yaml
OUTPUT_JSON         := .output.json

ifeq ($(AUTO_LOCAL_IP),true)
  TERRAFORM_ARGS += -var cluster_endpoint_public_access_cidrs='["$(shell curl -s https://api.ipify.org)/32"]'
endif


# TODO: Ler grupo usando terraform e injetar no configmap/aws-auth
# AWS_AUTH_GROUP_NAME := Infra
# AWS_AUTH_USER_ARNS ?= $(shell aws iam get-group --group-name $(AWS_AUTH_GROUP_NAME) | jq -cr '[.Users[].Arn]')

.ONESHELL:
.EXPORT_ALL_VARIABLES:

all help:
	@echo Targets:
	echo
	printf -- "- %s\n" init validate fmt plan apply overaly output kubeconfig update-version update-source clean destroy
	echo
	echo Reconcile flows:
	echo
	echo '- reconcile: $(FLOW_RECONCILE)'
	echo '- full-reconcile: $(FLOW_FULL_RECONCILE)'

reconcile: $(FLOW_RECONCILE)

full-reconcile: $(FLOW_FULL_RECONCILE)

pull:
	git pull origin main

commit:
	git commit -a -m "$(GIT_COMMIT_MESSAGE)"

push:
	git push $(GIT_REMOTE) $(GIT_BRANCH)

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
	$(TERRAFORM) output -json $(TERRAFORM_ARGS) $(TERRAFORM_OUTPUT_ARGS)

kubeconfig:
	aws eks update-kubeconfig --name=$(CLUSTER_NAME) $(AWS_EKS_ARGS)

update-version:
	latest=$$(timeout 3 curl -s https://raw.githubusercontent.com/getupcloud/terraform-modules/main/version.txt || echo 0.0.0)
	latest=$${latest}
	read -e -p "New module version: " -i "$$latest" v
	sed -i -e '/source/s/ref=v[0-9]\+\.[0-9]\+\.[0-9]\+/ref=v'$$v'/g' main-*tf

is-tree-clean:
ifneq ($(force), true)
	@if git status --porcelain | grep '^[^?]'; then
		git status;
		echo -e "\n>>> Tree is not clean. Please commit and try again <<<\n";
		exit 1;
	fi
endif

#update-source: update-from-remote-source
#
#update-from-remote-source:
#	# TODO

update-from-local-cluster: from ?= ../terraform-cluster/
update-from-local-cluster: patterns = $(filter-out versions.tf providers.tf,$(wildcard bin *.tf terraform-*.auto.tfvars.example))
update-from-local-cluster: sources = $(addprefix $(from)/, $(patterns))
update-from-local-cluster: is-tree-clean
	@shopt -s nullglob
	cp -rv $(sources) ./

update-from-local-examples: from ?= ../terraform-modules/examples
update-from-local-examples: sources = $(wildcard $(from)/*/*.tf $(from)/*/*.example $(from)/versions.tf)
update-from-local-examples: # is-tree-clean
	#@shopt -s nullglob
	cp -v $(sources) ./

$(OUTPUT_JSON): *.tf *.tfvars
	echo Generating $(OUTPUT_JSON)
	$(TERRAFORM) output -json $(TERRAFORM_ARGS) $(TERRAFORM_OUTPUT_ARGS) > $(OUTPUT_JSON)

show-overlay-vars:
	@grep -wrn -A 1 --color '#output:.*' cluster/overlay 2>/dev/null

overlay: $(OUTPUT_JSON)
	@echo Generating overlays
	find cluster/overlay -type f -iregex '.*\.ya?ml' | while read file; do
		echo $$file
		python bin/overlay.py $(OUTPUT_JSON) $$file >$${file}.tmp && mv $${file}.tmp $$file || exit 1
	done

validate-vars:
	@if [ -z "$(CLUSTER_NAME)" ]; then
		echo "Missing required var: CLUSTER_NAME"
		exit 1
	fi

kustomize ks:
	@echo Checking kustomization
	if ! kubectl kustomize ./cluster -o $(KUSTOMIZE_BUILD); then
		echo Generated output: $(KUSTOMIZE_BUILD)
		exit 1
	fi

