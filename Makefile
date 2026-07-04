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
