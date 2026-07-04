locals {
  # Default lifecycle policy
  default_lifecycle_policy = {
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  }

  lifecycle_policy_to_use = var.lifecycle_policy != null ? var.lifecycle_policy : (var.enable_default_lifecycle_policy ? local.default_lifecycle_policy : null)

  allowed_principals = length(var.allowed_principals) > 0 ? var.allowed_principals : ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecs-task-execution"]
}

resource "aws_ecr_repository" "this" {
  name                 = var.service_name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.repository_force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key_arn : null
  }

  tags = {
    Name = var.service_name
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode(local.lifecycle_policy_to_use)

  lifecycle {
    enabled = local.lifecycle_policy_to_use != null
  }
}

resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      length(local.allowed_principals) > 0 ? [{
        Sid    = "AllowPrincipalPull"
        Effect = "Allow"
        Principal = {
          AWS = local.allowed_principals
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }] : [],
      length(var.allowed_account_ids) > 0 ? [{
        Sid    = "AllowCrossAccountPull"
        Effect = "Allow"
        Principal = {
          AWS = [for account_id in var.allowed_account_ids : "arn:aws:iam::${account_id}:root"]
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }] : []
    )
  })

  lifecycle {
    enabled = length(var.allowed_principals) > 0 || length(var.allowed_account_ids) > 0
  }
}

resource "aws_ecr_replication_configuration" "this" {
  replication_configuration {
    dynamic "rule" {
      for_each = var.replication_configuration.rules
      content {
        dynamic "destination" {
          for_each = rule.value.destinations
          content {
            region      = destination.value.region
            registry_id = destination.value.registry_id
          }
        }

        dynamic "repository_filter" {
          for_each = rule.value.repository_filters != null ? rule.value.repository_filters : []
          content {
            filter      = repository_filter.value.filter
            filter_type = repository_filter.value.filter_type
          }
        }
      }
    }
  }

  lifecycle {
    enabled = var.enable_cross_account_replication && var.replication_configuration != null
  }
}
