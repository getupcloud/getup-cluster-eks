include Makefile.conf
-include Makefile.local
-include .env

# General variables
ROOT_DIR              := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
TERRAFORM             ?= terraform
TF_LOG_PATH           ?= terraform.log
TF_LOG                ?= DEBUG
CLUSTER_NAME          ?= $(shell sed -n -e 's|^[[:space:]]*cluster_name[[:space:]]*=[[:space:]]*"\([^"]*\)".*|\1|p' terraform-$(FLAVOR).auto.tfvars 2>/dev/null || true)
GIT_REMOTE            ?= origin
GIT_BRANCH            ?= main
GIT_COMMIT_MESSAGE    ?= Auto-generated commit
FLOW_RECONCILE        := plan apply overlay fmt commit push
FLOW_FULL_RECONCILE   := clean pull init validate $(FLOW_RECONCILE) kubeconfig
KUSTOMIZE_BUILD       := .kustomize_build.yaml
OUTPUT_JSON           := .output.json
OUTPUT_OVERLAY_JSON   := .overlay.output.json
TFVARS_OVERLAY_JSON   := .overlay.tfvars.json
MAIN_TF               := $(wildcard main-*.tf)
OUTPUTS_TF            := $(wildcard outputs-*.tf)
VARIABLES_TF          := $(wildcard variables-*.tf)
ALL_TF                := $(wildcard *.tf)
ALL_TFVARS            := $(wildcard *.tfvars)

# Helm vars
HELM_VALUES_TF        := helm-values.tf
VALUES_TERRAFORM_YAML := values-terraform.yaml
VALUES_CUSTOM_YAML    := values-custom.yaml
HELM_TEMPLATE_CMD     := helm template cluster cluster-chart --no-hooks --disable-openapi-validation --set cluster.clusterProvider=$(FLAVOR)

# Update vars
UPSTREAM_CLUSTER_DIR          ?= ../getup-cluster-$(FLAVOR)/
UPDATE_CLUSTER_FILES          := Makefile Makefile.conf bin cluster/base/* $(MODULES_TF)
MANIFESTS_BASE                := cluster/base
MANIFESTS_OVERLAY             := cluster/overlay cluster/kustomization.yaml
COMMON_FILES                  := Makefile Makefile.conf bin
UPDATE_OVERLAY_TARGET         ?= update-overlay # or update-overlay-meld

ifeq ($(AUTO_LOCAL_IP),true)
  TERRAFORM_ARGS += -var cluster_endpoint_public_access_cidrs='["$(shell curl -4 -s https://ifconfig.me)/32"]'
endif

.ONESHELL:
.EXPORT_ALL_VARIABLES:

.PHONY: all help
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

#
# Top-level targets
#
.PHONY: $(FLOW_FULL_RECONCILE) upgrade migrate-state

reconcile: $(FLOW_RECONCILE)

full-reconcile: $(FLOW_FULL_RECONCILE)

pull:
	git pull origin main

clean:
	rm -rf terraform.log $(OUTPUT_JSON) $(TFVARS_OVERLAY_JSON) $(VALUES_TERRAFORM_YAML)

clean-output:
	rm -f $(OUTPUT_JSON) $(OUTPUT_OVERLAY_JSON) $(TFVARS_OVERLAY_JSON)

clean-all: clean
	rm -rf .terraform

versions.tf: versions.tf.example
	@true
	if [ -e $@ ]; then
		tput setaf 1
		echo "The file $< is newer than $@. Please update $@ manually."
		echo "If this isn't necessary, just execute the command below and try again:"
		echo "$$ touch $@"
		tput sgr0
		exit 1
	fi
	cp -vi $< $@
	tput setaf 3
	echo "Update the file $@ first."
	tput sgr0
	exit 2

init: versions.tf validate-vars
	$(TERRAFORM) init $(TERRAFORM_ARGS) $(TERRAFORM_INIT_ARGS)

init-upgrade: validate-vars
	$(TERRAFORM) init -upgrade $(TERRAFORM_ARGS) $(TERRAFORM_INIT_ARGS)

validate: $(HELM_VALUES_TF) validate-vars
	$(TERRAFORM) validate $(TERRAFORM_ARGS) $(TERRAFORM_VALIDATE_ARGS)

plan: $(HELM_VALUES_TF) validate-vars
	$(TERRAFORM) plan -out terraform.tfplan $(TERRAFORM_ARGS) $(TERRAFORM_PLAN_ARGS)

apply:
	$(TERRAFORM) apply -auto-approve terraform.tfplan $(TERRAFORM_ARGS) $(TERRAFORM_APPLY_ARGS)

## Overlay
overlay: clean-output $(OUTPUT_OVERLAY_JSON) $(TFVARS_OVERLAY_JSON)
	@echo Processing overlays
	find cluster/overlay -type f -name '*.yaml' -o -name '*.yml' | sort -u | while read file; do
		bin/overlay "$$file" $(OUTPUT_OVERLAY_JSON) $(TFVARS_OVERLAY_JSON) >"$${file}.tmp" && mv "$${file}.tmp" "$$file" || exit 1
	done

$(OUTPUT_OVERLAY_JSON): $(OUTPUT_JSON)
	@echo Generating $@
	bin/output2overlay $^ > $@

$(TFVARS_OVERLAY_JSON): $(ALL_TFVARS)
	echo Generating $@
	bin/tfvars2overlay $^ > $@

## Helm Overlay
overlay-helm: manifests

fmt:
	$(TERRAFORM) fmt $(TERRAFORM_ARGS) $(TERRAFORM_FMT_ARGS)

commit:
	if git status --porcelain | grep -vE '^(\?\?|!!)'; then
		git add $(HELM_VALUES_TF)
		git commit -a -m "$(GIT_COMMIT_MESSAGE)"
	fi

push:
	git push $(GIT_REMOTE) $(GIT_BRANCH)

kubeconfig:
	$(KUBECONFIG_RETRIEVE_COMMAND)

migrate-state:
	$(TERRAFORM) init -migrate-state

#
# Validations
#
.PHONY: validate-vars is-tree-clean

validate-vars:
	@if [ -z "$(CLUSTER_NAME)" ]; then
		echo "Missing required var: CLUSTER_NAME"
		exit 1
	fi

kustomize:
	kustomize build cluster/ -o $(KUSTOMIZE_BUILD)

is-tree-clean:
ifneq ($(force), true)
	@if git status --porcelain | grep '^[^?]'; then
		git status;
		echo -e "\n>>> Tree is not clean. Please commit and try again <<<\n";
		exit 1;
	fi
endif

#
# Outputs
#
$(OUTPUT_JSON): $(ALL_TF) $(ALL_TFVARS)
	@echo Generating $@
	$(TERRAFORM) output -json $(TERRAFORM_ARGS) $(TERRAFORM_OUTPUT_ARGS) > $@

output: $(OUTPUT_JSON)
	$(TERRAFORM) output -json $(TERRAFORM_ARGS) $(TERRAFORM_OUTPUT_ARGS)

#
# Helm chart
#
.PHONY: manifests cluster2/%.yaml

$(HELM_VALUES_TF): $(filter-out $(HELM_VALUES_TF),$(wildcard $(ALL_TF) $(ALL_TFVARS)))
	@echo Building $@ from:
	python bin/mk-helm-values $(OUTPUTS_TF) | tr -d '\\' > $@

$(VALUES_TERRAFORM_YAML): $(OUTPUT_JSON) $(HELM_VALUES_TF)
	@echo Building $@ from $(OUTPUT_JSON)
	python bin/tf2values2 $(OUTPUT_JSON) | yq -P > $@

cluster2/%.yaml: $(VALUES_TERRAFORM_YAML) $(VALUES_CUSTOM_YAML)
	$(HELM_TEMPLATE_CMD) --values values-terraform.yaml --values values-custom.yaml --set mode.$*=true > $@

manifests: cluster2/kustomization.yaml cluster2/base.yaml cluster2/overlay.yaml

#
# Flux sugar
#
.PHONY: flux-%-%
flux-rec-sg frsg:
	flux reconcile source git flux-system
flux-rec-ks frks:
	flux reconcile kustomization flux-system

flux-sus-sg fssg:
	flux suspend source git flux-system
flux-sus-ks fsks:
	flux suspend kustomization flux-system

flux-res-sg fresg:
	flux resume source git flux-system
flux-res-ks fresks:
	flux resume kustomization flux-system

#
# Updates
# Used only to update upstream cluster repo, not to be meant to be used by end-users.
#

.PHONY: update-% upgrade-%
update-version:
	latest=$$(timeout 3 curl -s https://raw.githubusercontent.com/getupcloud/getup-modules/main/version.txt || echo 0.0.0)
	read -e -p "New module version: " -i "$$latest" v || read -e -p "New module version: [latest=$$latest]: " v
	sed=$$(type gsed &>/dev/null && echo gsed || echo sed)
	$$sed -i -e '/source/s/ref=v.*"/ref=v'$$v'"/g' main-*tf

########################################################

update: update-common update-terraform update-manifests
	@echo
	echo "--> Execute 'make $(UPDATE_OVERLAY_TARGET)' to see diff for overlay files <--"

update-common: from ?= $(UPSTREAM_CLUSTER_DIR)
update-common:
	@echo 'Checking common files'
	cd $(from) && rsync -av --omit-dir-times --info=all0,name1 --out-format='--> %f' --relative --ignore-missing-args \
		$(COMMON_FILES) $(ROOT_DIR)

update-terraform: from ?= $(UPSTREAM_CLUSTER_DIR)
update-terraform: update-common
	@echo 'Checking terraform files'
	cd $(from) && rsync -av --omit-dir-times --info=all0,name1 --out-format='--> %f' --relative --ignore-missing-args \
		$(MODULES_TF) $(ROOT_DIR)

update-manifests: from ?= $(UPSTREAM_CLUSTER_DIR)
update-manifests: update-common
	@echo 'Checking manifest files'
	cd $(from) && rsync -av --omit-dir-times --info=all0,name1 --out-format='--> %f' --relative --ignore-missing-args \
		$(MANIFESTS_BASE) $(ROOT_DIR)

update-overlay: from ?= $(UPSTREAM_CLUSTER_DIR)
update-overlay:
	@echo 'Checking overlay files'
	$(foreach source,$(MANIFESTS_OVERLAY),diff -prNu --color=always $(source) $(UPSTREAM_CLUSTER_DIR)/$(source) || true;)

update-overlay-meld: from ?= $(UPSTREAM_CLUSTER_DIR)
update-overlay-meld:
	@echo 'Checking overlay files (using meld)'
	$(foreach source,$(MANIFESTS_OVERLAY),meld --newtab $(source) $(UPSTREAM_CLUSTER_DIR)/$(source) || true;)

########################################################

# TO REMOVE ASAP
#
## copy files from modules defined in modules.yaml
#update-from-local-cluster: from   ?= $(UPSTREAM_CLUSTER_DIR)
#update-from-local-cluster: locals  = $(wildcard $(addprefix $(UPSTREAM_CLUSTER_DIR)/,$(UPDATE_CLUSTER_FILES)))
#update-from-local-cluster: is-tree-clean
#	@shopt -s nullglob
#	echo Updating local files only from $(from):
#	cd $(from) && rsync -av --omit-dir-times --info=all0,name1 --out-format='--> %f' --relative --ignore-missing-args $(locals) $(ROOT_DIR)
#
## copy all existing files from source
#upgrade-from-local-cluster: from ?= $(UPSTREAM_CLUSTER_DIR)
#upgrade-from-local-cluster: is-tree-clean
#	@shopt -s nullglob
#	echo Updating all files from $(from):
#	cd $(from) && rsync -av --omit-dir-times --info=all0,name1 --out-format='--> %f' --relative $(UPDATE_CLUSTER_FILES) $(ROOT_DIR)
#

#
# Delete resources and cluster
#
.PHONY: destroy destroy-%

destroy-cluster-resources:
	python bin/destroy-cluster-resources

destroy-cluster:
	$(TERRAFORM) destroy $(TERRAFORM_ARGS) $(TERRAFORM_DESTROY_ARGS)

destroy: destroy-cluster-resources destroy-cluster
	@echo 'Use "$(MAKE) destroy-cluster-resources-auto-approve" to destroy without asking.'

# WARNING: NO CONFIRMATION ON DESTROY
destroy-cluster-resources-auto-approve:
	python bin/destroy-cluster-resources --confirm-delete-cluster-resources

# WARNING: NO CONFIRMATION ON DESTROY
destroy-cluster-auto-approve: REGION ?= $(shell awk '/^region/{print $$3}' terraform-*.auto.tfvars | tr -d '"')
destroy-cluster-auto-approve:
	$(TERRAFORM) destroy -auto-approve $(TERRAFORM_ARGS) $(TERRAFORM_DESTROY_ARGS)

# WARNING: NO CONFIRMATION ON DESTROY
destroy-auto-approve: destroy-cluster-resources-auto-approve destroy-cluster-auto-approve
