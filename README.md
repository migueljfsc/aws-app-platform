# aws-app-platform

[![[Git] Release Version](https://github.com/migueljfsc/aws-app-platform/actions/workflows/release.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/release.yaml)
[![[Terraform] ACM](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-acm.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-acm.yaml)
[![[Terraform] ALB](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-alb.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-alb.yaml)
[![[Terraform] Budgets](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-budgets.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-budgets.yaml)
[![[Terraform] CloudFront](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-cloudfront.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-cloudfront.yaml)
[![[Terraform] IAM](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-iam.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-iam.yaml)
[![[Terraform] Network](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-network.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-network.yaml)
[![[Terraform] Quotas](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-quotas.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-quotas.yaml)
[![[Terraform] Route53](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-route53.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-route53.yaml)
[![[Terraform] S3](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-s3.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-s3.yaml)
[![[Terraform] WAF](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-waf.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-waf.yaml)
[![[Terraform] Github](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-github.yaml/badge.svg?branch=main)](https://github.com/migueljfsc/aws-app-platform/actions/workflows/terraform-github.yaml)

Monorepo for the app project infrastructure. Contains reusable OpenTofu modules and their concrete per-environment implementations.

## Repository Structure

```
infrastructure/terraform/
├── aws/          # Concrete implementations (per-environment resources)
│   ├── acm/      # ACM certificates
│   ├── alb/      # Application Load Balancers
│   ├── budgets/  # AWS Budgets + alerting
│   ├── iam/      # IAM users, groups, roles, policies
│   ├── network/  # VPC, subnets, NAT, security groups
│   ├── route53/  # DNS zones and records
│   └── waf/      # WAF Web ACLs and rules
└── modules/      # Reusable modules
    ├── ecr/      # Elastic Container Registry
    ├── ecs/      # ECS clusters, services, tasks
    ├── elasticache/ # ElastiCache (Redis / Memcached)
    ├── rds/      # RDS instances + replicas
    ├── registry/ # Tagging/metadata registry
    ├── s3/       # S3 buckets, policies, encryption
    └── sns/      # SNS topics and subscriptions
└── github/       # GitHub resources
```

## Prerequisites

| Tool | Version |
|------|---------|
| [OpenTofu](https://opentofu.org/) | `~> 1.11` |
| [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest) | `~> 6.0` |
| [TFLint](https://github.com/terraform-linters/tflint) | latest |
| [pre-commit](https://pre-commit.com/) | latest |

## Getting Started

1. **Install pre-commit hooks**

   ```bash
   pre-commit install --install-hooks
   ```

2. **Initialise a component** (e.g. `network`, `app-dev-euw3`)
   ```bash
   tofu -chdir=infrastructure/terraform/aws/network init -backend-config="bucket=infra-tf-state-dev-euw3" -backend-config="key=infra-aws-network/app-dev-euw3/terraform.tfstate" -backend-config="region=eu-west-3" -reconfigure
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
| `main` | Production |
| `feature/*` | New work |
| `hotfix/*` | Production fixes |

Commits follow [Conventional Commits](https://www.conventionalcommits.org/). Enforced via [Commitizen](https://commitizen-tools.github.io/commitizen/) pre-commit hook.

| Type | Semver bump |
|------|-------------|
| `feat` | minor |
| `feat!` / `BREAKING CHANGE` | major |
| `fix`, `docs`, `chore`, `ci`, `refactor`, `perf` | patch |

## Contributing

1. Branch from `main` (`feature/…` or `hotfix/…`)
2. Make changes and validate locally (see [Validation](#validation))
3. Open a PR — CI will run `tofu plan` automatically
4. Merge to `main` — CI applies the changes
