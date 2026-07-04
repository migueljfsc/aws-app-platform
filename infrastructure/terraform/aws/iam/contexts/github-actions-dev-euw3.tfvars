environment  = "dev"
service_name = "github-actions"

# ==========================================
# OIDC Provider
# ==========================================
oidc_providers = {
  github = {
    url            = "https://token.actions.githubusercontent.com"
    client_id_list = ["sts.amazonaws.com"]
    # Including both standard GitHub Actions thumbprints for safety/rotation
    thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
  }
}

# ==========================================
# Roles (Identities & Trust Policies)
# ==========================================
roles = {
  # 1. ECR Builder Role
  github-actions-ecr-builder = {
    description = "GitHub Actions role for building and pushing Docker images"
    assume_role_policy = {
      action = "sts:AssumeRoleWithWebIdentity"
      principals = [{
        type        = "Federated"
        identifiers = ["arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"]
      }]
      conditions = [
        {
          test     = "StringLike"
          variable = "token.actions.githubusercontent.com:sub"
          values   = ["repo:migueljfsc/app*"]
        },
        {
          test     = "StringEquals"
          variable = "token.actions.githubusercontent.com:aud"
          values   = ["sts.amazonaws.com"]
        }
      ]
    }
  }

  # 2. ECS Deployer Role
  github-actions-ecs-deployer = {
    description = "GitHub Actions role for deploying new task definitions to ECS"
    assume_role_policy = {
      action = "sts:AssumeRoleWithWebIdentity"
      principals = [{
        type        = "Federated"
        identifiers = ["arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"]
      }]
      conditions = [
        {
          test     = "StringLike"
          variable = "token.actions.githubusercontent.com:sub"
          values   = ["repo:migueljfsc/app*"]
        },
        {
          test     = "StringEquals"
          variable = "token.actions.githubusercontent.com:aud"
          values   = ["sts.amazonaws.com"]
        }
      ]
    }
  }

  # 3. Terraform Infra Plan Role
  github-actions-infra-plan = {
    description = "GitHub Actions role for running Terraform plan (read-only)"
    assume_role_policy = {
      action = "sts:AssumeRoleWithWebIdentity"
      principals = [{
        type        = "Federated"
        identifiers = ["arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"]
      }]
      conditions = [
        {
          test     = "StringLike"
          variable = "token.actions.githubusercontent.com:sub"
          values   = ["repo:migueljfsc/app*"]
        },
        {
          test     = "StringEquals"
          variable = "token.actions.githubusercontent.com:aud"
          values   = ["sts.amazonaws.com"]
        }
      ]
    }
  }

  # 4. Terraform Infra Apply Role
  github-actions-infra-apply = {
    description = "GitHub Actions role for running Terraform apply"
    assume_role_policy = {
      action = "sts:AssumeRoleWithWebIdentity"
      principals = [{
        type        = "Federated"
        identifiers = ["arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"]
      }]
      conditions = [
        {
          test     = "StringLike"
          variable = "token.actions.githubusercontent.com:sub"
          values   = ["repo:migueljfsc/app*"]
        },
        {
          test     = "StringEquals"
          variable = "token.actions.githubusercontent.com:aud"
          values   = ["sts.amazonaws.com"]
        }
      ]
    }
  }
}

# ==========================================
# Role Inline Policies (Permissions)
# ==========================================
role_policies = {

  # ----------------------------------------
  # ECR Builder Permissions
  # ----------------------------------------
  ecr-builder-auth = {
    role_key = "github-actions-ecr-builder"
    policy_statements = [{
      sid        = "GetAuthorizationToken"
      effect     = "Allow"
      actions    = ["ecr:GetAuthorizationToken"]
      resources  = ["*"]
      conditions = []
    }]
  }

  ecr-builder-push = {
    role_key = "github-actions-ecr-builder"
    policy_statements = [{
      sid    = "AllowPushPull"
      effect = "Allow"
      actions = [
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ]
      resources  = ["arn:aws:ecr:eu-west-3:123456789012:repository/*"]
      conditions = []
    }]
  }

  # ----------------------------------------
  # ECS Deployer Permissions
  # ----------------------------------------
  ecs-deployer-update = {
    role_key = "github-actions-ecs-deployer"
    policy_statements = [
      {
        sid    = "AllowECSUpdate"
        effect = "Allow"
        actions = [
          "ecs:UpdateService",
          "ecs:TagResource"
        ]
        resources = ["*"]
      },
      {
        sid    = "AllowGlobalECSRead"
        effect = "Allow"
        actions = [
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeServices"
        ]
        resources = ["*"]
      },
      {
        sid     = "AllowPassRoleToECS"
        effect  = "Allow"
        actions = ["iam:PassRole"]
        resources = [
          "arn:aws:iam::123456789012:role/*-ecs-task",
          "arn:aws:iam::123456789012:role/*-ecs-task-execution"
        ]
        conditions = [
          {
            test     = "StringEquals"
            variable = "iam:PassedToService"
            values   = ["ecs-tasks.amazonaws.com"]
          }
        ]
      }
    ]
  }

  # ----------------------------------------
  # Terraform Infra Plan Permissions
  # ----------------------------------------
  infra-plan-terraform = {
    role_key = "github-actions-infra-plan"
    policy_statements = [
      # 1. STATE MANAGEMENT
      {
        sid    = "TerraformStateManagement"
        effect = "Allow"
        actions = [
          "s3:ListBucket",
          "s3:GetObject",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        resources = [
          "arn:aws:s3:::infra-tf-state-*",
          "arn:aws:s3:::infra-tf-state-*/*"
        ]
      },
      # 2. GLOBAL DISCOVERY & ROUTE53
      {
        sid    = "TerraformGlobalDiscovery"
        effect = "Allow"
        actions = [
          "kms:Describe*", "kms:List*", "kms:Get*",
          "ec2:Describe*", "ec2:List*", "ec2:Get*",
          "ecs:Describe*", "ecs:List*", "ecs:Get*",
          "autoscaling:Describe*", "autoscaling:List*", "autoscaling:Get*",
          "rds:Describe*", "rds:List*", "rds:Get*",
          "s3:Describe*", "s3:List*", "s3:Get*",
          "elasticache:Describe*", "elasticache:List*", "elasticache:Get*",
          "elasticloadbalancing:Describe*", "elasticloadbalancing:List*", "elasticloadbalancing:Get*",
          "ecr:Describe*", "ecr:List*", "ecr:Get*", "ecr:BatchGetImage",
          "acm:Describe*", "acm:List*", "acm:Get*",
          "iam:Describe*", "iam:List*", "iam:Get*",
          "route53:List*", "route53:Get*",
          "secretsmanager:Get*", "secretsmanager:List*", "secretsmanager:Describe*",
          "sns:Describe*", "sns:List*", "sns:Get*",
          "logs:Describe*", "logs:List*", "logs:Get*",
          "budgets:Describe*", "budgets:List*", "budgets:Get*", "budgets:View*",
          "wafv2:Describe*", "wafv2:List*", "wafv2:Get*", "wafv2:CheckCapacity",
          "servicequotas:Describe*", "servicequotas:List*", "servicequotas:Get*", "servicequotas:View*",
          "cloudfront:Describe*", "cloudfront:List*", "cloudfront:Get*", "cloudfront:CheckCapacity",
          "ce:Describe*", "ce:Get*", "ce:List*", "ce:View*",
          "apigateway:Describe*", "apigateway:List*", "apigateway:Get*", "apigateway:View*",
          "lambda:Describe*", "lambda:List*", "lambda:Get*", "lambda:View*"
        ]
        resources = ["*"]
      }
    ]
  }

  # ----------------------------------------
  # Terraform Infra Apply Permissions
  # ----------------------------------------
  infra-apply-terraform = {
    role_key = "github-actions-infra-apply"
    policy_statements = [
      # 1. STATE MANAGEMENT
      {
        sid    = "TerraformStateManagement"
        effect = "Allow"
        actions = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        resources = [
          "arn:aws:s3:::infra-tf-state-*",
          "arn:aws:s3:::infra-tf-state-*/*"
        ]
      },
      # 3. IAM PASSROLE FOR ECS
      {
        sid     = "AllowPassRoleToECS"
        effect  = "Allow"
        actions = ["iam:PassRole"]
        resources = [
          "arn:aws:iam::123456789012:role/*-ecs-task",
          "arn:aws:iam::123456789012:role/ecs-task-execution"
        ]
        conditions = [
          {
            test     = "StringEquals"
            variable = "iam:PassedToService"
            values   = ["ecs-tasks.amazonaws.com"]
          }
        ]
      },
      # 4. TAG-RESTRICTED EXECUTION
      {
        sid    = "TerraformApply"
        effect = "Allow"
        actions = [
          "kms:*",
          "ec2:*",
          "ecs:*",
          "autoscaling:*",
          "rds:*",
          "s3:*",
          "elasticache:*",
          "elasticloadbalancing:*",
          "ecr:*",
          "route53:*",
          "acm:*",
          "sns:*",
          "ce:*",
          "logs:*",
          "budgets:*",
          "secretsmanager:*",
          "wafv2:*",
          "iam:*",
          "servicequotas:*",
          "cloudfront:*",
          "apigateway:*",
          "lambda:*"
        ]
        resources = ["*"]
      }
    ]
  }
}
