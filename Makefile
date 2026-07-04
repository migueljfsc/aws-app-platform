# =============================================================================
# Variables
# =============================================================================
TOFU_STATE_BUCKET=app-infra-tf-state
TOFU_STATE_REGION=eu-west-3
TOFU_CHDIR=infrastructure/terraform/aws/acm
TOFU_STATE_KEY=infra-aws-acm/app-dev-euw3/terraform.tfstate
TOFU_VAR_FILE=contexts/app-dev-euw3.tfvars

# =============================================================================
# Phony
# =============================================================================

.PHONY: tofu-init tofu-plan tofu-apply tofu-destroy

# =============================================================================
# OpenTofu
# =============================================================================

tofu-init:
	tofu -chdir=$(TOFU_CHDIR) init \
		-backend-config="bucket=$(TOFU_STATE_BUCKET)" \
		-backend-config="key=$(TOFU_STATE_KEY)" \
		-backend-config="region=$(TOFU_STATE_REGION)" \
		-reconfigure

tofu-apply:
	tofu -chdir=$(TOFU_CHDIR) apply \
		-var-file=$(TOFU_VAR_FILE)

# =============================================================================
# LocalStack (mock AWS) — see localstack/README.md
# Runs OpenTofu against LocalStack via the `tofulocal` wrapper (terraform-local).
# Free-tier components: s3, iam. Override with COMPONENT / CONTEXT.
# =============================================================================
TFLOCAL          ?= tflocal
LS_COMPONENT     ?= s3
LS_CONTEXT       ?= app-infra-tf-state-dev-euw3
LS_CHDIR          = infrastructure/terraform/aws/$(LS_COMPONENT)
LS_STATE_BUCKET  ?= tflocal-state

export TF_CMD                ?= tofu # make tflocal drive OpenTofu
export AWS_ACCESS_KEY_ID     ?= test
export AWS_SECRET_ACCESS_KEY ?= test
export AWS_DEFAULT_REGION    ?= us-east-1
export AWS_ENDPOINT_URL      ?= http://localhost:4566

.PHONY: ls-up ls-down ls-bucket ls-init ls-plan ls-apply ls-destroy

ls-up:
	docker compose -f localstack/docker-compose.yml up -d
	@echo "waiting for LocalStack..."
	@until curl -sf http://localhost:4566/_localstack/health >/dev/null 2>&1; do sleep 1; done
	@echo "LocalStack ready on http://localhost:4566"

ls-down:
	docker compose -f localstack/docker-compose.yml down

ls-bucket:
	aws --endpoint-url $(AWS_ENDPOINT_URL) s3api create-bucket \
		--bucket $(LS_STATE_BUCKET) --region $(AWS_DEFAULT_REGION) || true

ls-init: ls-bucket
	$(TFLOCAL) -chdir=$(LS_CHDIR) init \
		-backend-config="bucket=$(LS_STATE_BUCKET)" \
		-backend-config="key=$(LS_COMPONENT)-$(LS_CONTEXT)/terraform.tfstate" \
		-backend-config="region=$(AWS_DEFAULT_REGION)" \
		-reconfigure

ls-plan: ls-init
	$(TFLOCAL) -chdir=$(LS_CHDIR) plan -var-file=contexts/$(LS_CONTEXT).tfvars

ls-apply: ls-init
	$(TFLOCAL) -chdir=$(LS_CHDIR) apply -auto-approve -var-file=contexts/$(LS_CONTEXT).tfvars

ls-destroy: ls-init
	$(TFLOCAL) -chdir=$(LS_CHDIR) destroy -auto-approve -var-file=contexts/$(LS_CONTEXT).tfvars
