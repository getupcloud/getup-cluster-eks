#
# You can use this Makefile to create resources using the modules from this repo.
# This is a suggestion, not a requirement.
#

include Makefile.conf

# General variables
TERRAFORM           ?= terraform
TF_LOG_PATH         ?= terraform.log
TF_LOG              ?= DEBUG
CLUSTER_NAME        ?= $(shell sed -n -e 's|^[[:space:]]*cluster_name[[:space:]]*=[[:space:]]*"\([^"]*\)".*|\1|p' *.tfvars 2>/dev/null)
GIT_REMOTE          ?= origin
GIT_BRANCH          ?= main
GIT_COMMIT_MESSAGE  ?= Auto-generated commit
FLOW_RECONCILE      := plan apply overlay commit push
FLOW_FULL_RECONCILE := pull init validate plan apply kubeconfig overlay commit push
KUSTOMIZE_BUILD     := .kustomize_build.yaml
OUTPUT_JSON         := .output.json
OUTPUT_OVERLAY_JSON := .overlay.output.json
TFVARS_OVERLAY_JSON := .overlay.tfvars.json
ROOT_DIR            := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))


UPSTREAM_CLUSTER_DIR          ?= ../getup-cluster-$(FLAVOR)/
UPSTREAM_EXAMPLES_COMMON_DIR  ?= ../getup-modules/examples/common
UPSTREAM_EXAMPLES_CLUSTER_DIR ?= ../getup-modules/examples/$(FLAVOR)
UPDATE_CLUSTER_FILES          := Makefile bin cluster/base/* *.tf *.example
UPDATE_EXAMPLES_CLUSTER_FILES := *.tf *.example */*.tf */*.example
UPDATE_EXAMPLES_COMMON_FILES  := *.tf *.example

ifeq ($(AUTO_LOCAL_IP),true)
  TERRAFORM_ARGS += -var cluster_endpoint_public_access_cidrs='["$(shell curl -s https://api.ipify.org)/32"]'
endif

-include .env

.ONESHELL:
.EXPORT_ALL_VARIABLES:

all help:
	@echo Available targets
	echo
	echo "Terraform commands"
	echo "  init          Executes 'terraform init'"
	echo "  validate      Executes 'terraform validate'"
	echo "  fmt           Executes 'terraform fmt'"
	echo "  apply         Executes 'terraform apply'"
	echo "  validate      Executes 'terraform validate'"
	echo
	echo "Git commands"
	echo "  overlay      Updates ./clustetr/overlay using data from terraform output and tfvars"
	echo "  commit       Executes 'git commit' using default message"
	echo "  push         Executes 'git push'"
	echo
	echo "Flux commands"
	echo "  flux-rec-sg    Reconcile GitRepository/flux-system"
	echo "  flux-rec-ks    Reconcile Kustomization/flux-system"
	echo "  flux-sus-sg    Suspend GitRepository/flux-system"
	echo "  flux-sus-ks    Suspend Kustomization/flux-system"
	echo "  flux-res-sg    Resume GitRepository/flux-system"
	echo "  flux-res-ks    Resume Kustomization/flux-system"
	echo
	echo "Pre-defined reconcile flows"
	echo
	echo "  reconcile        $(FLOW_RECONCILE)"
	echo "  full-reconcile   $(FLOW_FULL_RECONCILE)"

reconcile: $(FLOW_RECONCILE)

full-reconcile: $(FLOW_FULL_RECONCILE)

pull:
	git pull origin main

commit:
	git status --porcelain | grep -vE '^(\?\?|!!)' && git commit -a -m "$(GIT_COMMIT_MESSAGE)" || true

push:
	git push $(GIT_REMOTE) $(GIT_BRANCH)

clean:
	rm -rf .terraform terraform.log $(KUSTOMIZE_BUILD)

clean-output:
	@rm -f $(OUTPUT_JSON) $(OUTPUT_OVERLAY_JSON) $(TFVARS_OVERLAY_JSON)

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

migrate-state:
	$(TERRAFORM) init -migrate-state

# WARNING: NO CONFIRMATION ON APPLY
apply:
	$(TERRAFORM) apply -auto-approve terraform.tfplan $(TERRAFORM_ARGS) $(TERRAFORM_APPLY_ARGS)

flux-rec-sg fr:
	flux reconcile source git flux-system
flux-rec-ks:
	flux reconcile kustomization flux-system
flux-sus-sg:
	flux suspend source git flux-system
flux-sus-ks:
	flux suspend kustomization flux-system
flux-res-sg:
	flux resume source git flux-system
flux-res-ks:
	flux resume kustomization flux-system

#################################################################################################

destroy-cluster-resources:
	python bin/destroy-cluster-resources

destroy-cluster:
	$(TERRAFORM) destroy $(TERRAFORM_ARGS) $(TERRAFORM_DESTROY_ARGS)

destroy: destroy-cluster-resources destroy-cluster
	@echo 'Use "$(MAKE) destroy-cluster-resources-auto-approve" to destroy without asking.'

#################################################################################################

# WARNING: NO CONFIRMATION ON DESTROY
destroy-cluster-resources-auto-approve:
	python bin/destroy-cluster-resources --confirm-delete-cluster-resources

# WARNING: NO CONFIRMATION ON DESTROY
destroy-cluster-auto-approve: REGION ?= $(shell awk '/^region/{print $$3}' terraform-*.auto.tfvars | tr -d '"')
destroy-cluster-auto-approve:
	$(TERRAFORM) destroy -auto-approve $(TERRAFORM_ARGS) $(TERRAFORM_DESTROY_ARGS)

# WARNING: NO CONFIRMATION ON DESTROY
destroy-auto-approve: destroy-cluster-resources-auto-approve destroy-cluster-auto-approve

#################################################################################################

output:
	$(TERRAFORM) output -json $(TERRAFORM_ARGS) $(TERRAFORM_OUTPUT_ARGS)

kubeconfig: REGION ?= $(shell awk '/^region/{print $$3}' terraform-*.auto.tfvars | tr -d '"')
kubeconfig:
	$(KUBECONFIG_RETRIEVE_COMMAND)

update-version:
	latest=$$(timeout 3 curl -s https://raw.githubusercontent.com/getupcloud/getup-modules/main/version.txt || echo 0.0.0)
	read -e -p "New module version: " -i "$$latest" v || read -e -p "New module version: [latest=$$latest]: " v
	sed=$$(type gsed &>/dev/null && echo gsed || echo sed)
	$$sed -i -e '/source/s/ref=v.*"/ref=v'$$v'"/g' main-*tf

is-tree-clean:
ifneq ($(force), true)
	@if git status --porcelain | grep '^[^?]'; then
		git status;
		echo -e "\n>>> Tree is not clean. Please commit and try again <<<\n";
		exit 1;
	fi
endif

# copy only locally existing files from source
update-from-local-cluster: from   ?= $(UPSTREAM_CLUSTER_DIR)
update-from-local-cluster: locals  = $(wildcard $(UPDATE_CLUSTER_FILES))
update-from-local-cluster: #is-tree-clean
	@shopt -s nullglob
	echo Updating local files only from $(from):
	cd $(from) && rsync -av --omit-dir-times --info=all0,name1 --out-format='--> %f' --relative --ignore-missing-args $(locals) $(ROOT_DIR)

# copy all existing files from source
upgrade-from-local-cluster: from ?= $(UPSTREAM_CLUSTER_DIR)
upgrade-from-local-cluster: #is-tree-clean
	@shopt -s nullglob
	echo Updating all files from $(from):
	cd $(from) && rsync -av --omit-dir-times --info=all0,name1 --out-format='--> %f' --relative $(UPDATE_CLUSTER_FILES) $(ROOT_DIR)

#
# used only to update upstream cluster repo, not to be meant to be used by end-users.
#
upgrade-from-local-examples-common: from ?= $(UPSTREAM_EXAMPLES_COMMON_DIR)
upgrade-from-local-examples-common: #is-tree-clean
	shopt -s nullglob
	echo Updating examples from $(from):
	cd $(from) && rsync -av --omit-dir-times --info=all0,name1 --out-format='--> %f' $(UPDATE_EXAMPLES_COMMON_FILES) $(ROOT_DIR)

upgrade-from-local-examples: from ?= $(UPSTREAM_EXAMPLES_CLUSTER_DIR)
upgrade-from-local-examples: upgrade-from-local-examples-common #is-tree-clean
	shopt -s nullglob
	echo Updating examples from $(from):
	cd $(from) && rsync -av --omit-dir-times --info=all0,name1 --out-format='--> %f' $(UPDATE_EXAMPLES_CLUSTER_FILES) $(ROOT_DIR)

show-overlay-vars:
	@grep -wrn -A 1 --color '#output:.*' cluster/overlay 2>/dev/null

$(OUTPUT_JSON): *.tf *.tfvars
	@echo Generating $@
	$(TERRAFORM) output -json $(TERRAFORM_ARGS) $(TERRAFORM_OUTPUT_ARGS) > $(OUTPUT_JSON)

$(OUTPUT_OVERLAY_JSON): $(OUTPUT_JSON)
	@echo Generating $@
	bin/output2overlay $^ > $@

$(TFVARS_OVERLAY_JSON): *.tfvars
	@echo Generating $@
	bin/tfvars2overlay $^ > $@

overlay: clean-output $(OUTPUT_OVERLAY_JSON) $(TFVARS_OVERLAY_JSON)
	@echo Processing overlays
	find cluster/overlay -type f -name '*.yaml' -o -name '*.yml' | sort -u | while read file; do
		bin/overlay "$$file" $(OUTPUT_OVERLAY_JSON) $(TFVARS_OVERLAY_JSON) >"$${file}.tmp" && mv "$${file}.tmp" "$$file" || exit 1
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
