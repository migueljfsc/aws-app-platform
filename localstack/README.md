# LocalStack (mock AWS)

Run the Terraform against a local mock of AWS — no account, no credentials, no
cost. Uses [LocalStack](https://localstack.cloud/) plus the
[`tofulocal`](https://github.com/localstack/terraform-local) wrapper, which
points every AWS endpoint (and the S3 state backend) at LocalStack with dummy
credentials. **No changes to the Terraform are required.**

## Prerequisites

- Docker
- OpenTofu
- `pip install terraform-local` (provides `tflocal`; the Makefile sets
  `TF_CMD=tofu` so it drives OpenTofu instead of Terraform)

## Usage

```bash
make ls-up                         # start LocalStack (localhost:4566)

make ls-apply LS_COMPONENT=s3  LS_CONTEXT=app-infra-tf-state-dev-euw3
make ls-apply LS_COMPONENT=iam LS_CONTEXT=ecs-dev-euw3

make ls-plan  LS_COMPONENT=iam LS_CONTEXT=github-actions-dev-euw3
make ls-destroy LS_COMPONENT=s3 LS_CONTEXT=app-infra-tf-state-dev-euw3

make ls-down                       # stop LocalStack
```

## Service coverage

LocalStack's **free Community** edition only mocks part of the stack. These
components run end-to-end on the free tier and are exercised by the
`[LocalStack] Terraform` CI workflow:

| Component | Notes |
|-----------|-------|
| `s3`  | state bucket — fully supported |
| `iam` | roles, policies, OIDC/SAML providers — fully supported |
| `route53` (public) | `public-app-dev-euw3` — public hosted zone; data sources disabled for public zones (`private_zone=false`, `create_zone=true`) |
| `route53` (private) | `private-app-dev-euw3` — private hosted zone; CI seeds a VPC (`ec2 create-vpc`) and points `vpc_name` at it, standing in for the Pro `network` component |

The following need **LocalStack Pro** (`LOCALSTACK_AUTH_TOKEN`), so they are not
wired into CI:

| Component | Reason |
|-----------|--------|
| `network` | reads/creates Transit Gateway resources (Pro) |
| `alb`, `cloudfront`, `waf`, `acm`, `api-gateway`, `ecs`, `rds`, `elasticache`, `budgets`, `quotas` | Pro-only services |

> LocalStack reports account id `000000000000`; the registry tags such deploys
> `AwsAccountName = UnknownAccount`, which is expected.
