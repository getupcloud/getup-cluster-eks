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
OUTPUT_OVERLAY_JSON := .overlay.output.json
TFVARS_OVERLAY_JSON := .overlay.tfvars.json

UPDATE_FILES_CLUSTER = bin/ providers.tf main-*.tf variables-*.tf outputs-*.tf terraform-*.auto.tfvars.example

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
	printf -- "- %s\n" init validate fmt plan apply overaly output kubeconfig update-version clean destroy migrate-state
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

migrate-state:
	$(TERRAFORM) init -migrate-state

# WARNING: NO CONFIRMATION ON APPLY
apply:
	$(TERRAFORM) apply -auto-approve terraform.tfplan $(TERRAFORM_ARGS) $(TERRAFORM_APPLY_ARGS)

#################################################################################################

destroy-cluster-resources:
	python bin/destroy-cluster-resources

destroy-eks:
	$(TERRAFORM) destroy $(TERRAFORM_ARGS) $(TERRAFORM_DESTROY_ARGS)

destroy: destroy-cluster-resources destroy-eks

#################################################################################################

# WARNING: NO CONFIRMATION ON DESTROY
destroy-cluster-resources-auto-approve:
	python bin/destroy-cluster-resources --confirm-delete-cluster-resources

# WARNING: NO CONFIRMATION ON DESTROY
destroy-eks-auto-approve: AWS_REGION ?= $(shell awk '/^aws_region/{print $$3}' terraform-eks.auto.tfvars | tr -d '"')
destroy-eks-auto-approve:
	SG_ID=$$(aws ec2 describe-security-groups --filters 'Name=tag:aws:eks:cluster-name,Values=$(CLUSTER_NAME)' --region $(AWS_REGION) \
		| jq -r '.SecurityGroups[]|.GroupId // empty')
	if [ -n "$$SG_ID" ]; then
		aws ec2 delete-security-group --group-id  "$$SG_ID" --region $(AWS_REGION)
	fi
	$(TERRAFORM) destroy -auto-approve $(TERRAFORM_ARGS) $(TERRAFORM_DESTROY_ARGS)

# WARNING: NO CONFIRMATION ON DESTROY
destroy-auto-approve: destroy-cluster-resources-auto-approve destroy-eks-auto-approve

#################################################################################################

output:
	$(TERRAFORM) output -json $(TERRAFORM_ARGS) $(TERRAFORM_OUTPUT_ARGS)

kubeconfig: AWS_REGION ?= $(shell awk '/^aws_region/{print $$3}' terraform-eks.auto.tfvars | tr -d '"')
kubeconfig:
	aws eks update-kubeconfig --name=$(CLUSTER_NAME) $(AWS_EKS_ARGS) --region $(AWS_REGION)

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

# copy only locally existing files from source
update-from-local-cluster: from ?= ../terraform-cluster/
update-from-local-cluster: sources ?= $(addprefix $(from)/,$(wildcard $(UPDATE_FILES_CLUSTER)))
update-from-local-cluster: is-tree-clean
	@shopt -s nullglob
	cp -rv $(sources) ./

# copy all existing files from source
upgrade-from-local-cluster: from ?= ../terraform-cluster/
upgrade-from-local-cluster: sources ?= $(wildcard $(addprefix $(from)/,$(UPDATE_FILES_CLUSTER)))
upgrade-from-local-cluster: is-tree-clean
	@shopt -s nullglob
	cp -rv $(sources) ./

update-from-local-examples: from ?= ../terraform-modules/examples
update-from-local-examples: sources = $(wildcard $(from)/*/*.tf $(from)/*/*.example $(from)/versions.tf)
update-from-local-examples: is-tree-clean
	@shopt -s nullglob
	cp -rv $(sources) ./

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

overlay: $(OUTPUT_OVERLAY_JSON) $(TFVARS_OVERLAY_JSON)
	@echo Processing overlays
	find cluster/overlay -type f -iregex '.*\.ya?ml' | while read file; do
		echo "-> $$file"
		bin/overlay "$$file" $^ >"$${file}.tmp" && mv "$${file}.tmp" "$$file" || exit 1
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

