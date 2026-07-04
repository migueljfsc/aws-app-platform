# aws-app-platform

[![Release](https://github.com/migueljfsc/aws-app-platform/actions/workflows/release.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/release.yaml)
[![Infra Deploy](https://github.com/migueljfsc/aws-app-platform/actions/workflows/infra_deploy.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/infra_deploy.yaml)
[![LocalStack](https://github.com/migueljfsc/aws-app-platform/actions/workflows/localstack.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/localstack.yaml)

Portfolio monorepo for an AWS application platform, provisioned with OpenTofu.
Contains reusable Terraform modules, their concrete per-environment stacks, and a
minimal containerised application layer deployed to ECS.

## Repository Structure

```
.
├── infrastructure/terraform/
│   ├── aws/              # Per-environment resource stacks
│   │   ├── acm/            # ACM certificates
│   │   ├── alb/            # Application Load Balancers
│   │   ├── api-gateway/    # HTTP / REST API Gateway
│   │   ├── budgets/        # AWS Budgets + cost anomaly alerting
│   │   ├── cloudfront/     # CloudFront distributions
│   │   ├── ec2/            # Bastion host
│   │   ├── iam/            # IAM roles, policies, OIDC providers
│   │   ├── network/        # VPC, subnets, NAT, security groups
│   │   ├── quotas/         # Service quota requests
│   │   ├── route53/        # DNS hosted zones and records
│   │   ├── s3/             # Terraform state bucket
│   │   └── waf/            # WAF Web ACLs and rules
│   └── modules/          # Reusable modules
│       ├── ecr/            # Elastic Container Registry
│       ├── ecs/            # ECS clusters, services, tasks
│       ├── elasticache/    # ElastiCache (Redis / Valkey / Memcached)
│       ├── github/         # GitHub repository rulesets
│       ├── lambda/         # Lambda functions
│       ├── rds/            # RDS instances + replicas
│       ├── registry/       # Tagging / deploy-context registry
│       ├── s3/             # S3 buckets, policies, encryption
│       └── sns/            # SNS topics and subscriptions
├── app/                  # Application layer (see app/README.md)
│   ├── server.js           # Minimal zero-dependency frontend service
│   ├── Dockerfile
│   └── infrastructure/     # Terraform for the app (frontend/backend ECS, GitHub)
└── .github/
    ├── workflows/          # infra_deploy.yaml (matrix), terraform-manual, release, …
    ├── actions/terraform/  # Reusable composite action (auth + plan/apply)
    └── infra-components.json  # Component catalog that drives the deploy matrix
```

## Prerequisites

| Tool | Version |
|------|---------|
| [OpenTofu](https://opentofu.org/) | `~> 1.11` |
| [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest) | `~> 6.0` |
| [TFLint](https://github.com/terraform-linters/tflint) | latest |
| [pre-commit](https://pre-commit.com/) | latest |

## CI/CD

All infrastructure is deployed by a single workflow — `.github/workflows/infra_deploy.yaml`:

- A **detect** job diffs the changed files and builds a matrix from
  `.github/infra-components.json`, so only the components you touched are run.
  A change to the `registry` module or the composite action re-runs everything.
- A **deploy** job runs each selected component in parallel through the reusable
  `./.github/actions/terraform` action — `plan` on pull requests, `apply` on push
  to `main`.
- AWS access uses short-lived OIDC role assumption — no static keys.

Add or remove a component by editing the JSON catalog; the workflow is unchanged.
One-off runs (any component, plan → approve → apply) use `terraform-manual.yaml`.

### Local testing without an AWS account

The stack can be applied against a **mock AWS** (no account, no cost) using
[LocalStack](https://localstack.cloud/) — see [`localstack/`](localstack/). The
free tier covers `s3` and `iam` end-to-end (exercised by the `localstack.yaml`
CI workflow); other components need LocalStack Pro.

```bash
make ls-up
make ls-apply LS_COMPONENT=s3 LS_CONTEXT=app-infra-tf-state-dev-euw3
```

## Getting Started (local plan)

1. **Install pre-commit hooks**

   ```bash
   pre-commit install --install-hooks
   ```

2. **Initialise a component** (e.g. `network`, context `app-dev-euw3`)

   ```bash
   tofu -chdir=infrastructure/terraform/aws/network init \
     -backend-config="bucket=app-infra-tf-state" \
     -backend-config="key=infra-aws-network/app-dev-euw3/terraform.tfstate" \
     -backend-config="region=eu-west-3" -reconfigure
   ```

3. **Plan changes**

   ```bash
   tofu -chdir=infrastructure/terraform/aws/network plan -var-file=contexts/app-dev-euw3.tfvars
   ```

> [!IMPORTANT]
> Never run `tofu apply` or `tofu destroy` locally. All provisioning is handled by GitHub Actions.

## Validation

```bash
tofu fmt -check -recursive
tofu validate
tflint
```

## Branching & Commits

| Branch | Purpose |
|--------|---------|
| `main` | Deployed environment (`dev`) |
| `feature/*` | New work |
| `hotfix/*` | Fixes |

Commits follow [Conventional Commits](https://www.conventionalcommits.org/), enforced via a [Commitizen](https://commitizen-tools.github.io/commitizen/) pre-commit hook.

| Type | Semver bump |
|------|-------------|
| `feat` | minor |
| `feat!` / `BREAKING CHANGE` | major |
| `fix`, `docs`, `chore`, `ci`, `refactor`, `perf` | patch |

## Contributing

1. Branch from `main` (`feature/…` or `hotfix/…`)
2. Make changes and validate locally (see [Validation](#validation))
3. Open a PR — CI runs `tofu plan` for the affected components
4. Merge to `main` — CI applies the changes
