# Lambda Execution Role
resource "aws_iam_role" "this" {
  for_each = {
    for k, v in var.functions : k => v if v.create_role
  }

  name = "${var.service_name}-${var.deploy_context}-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.service_name}-${var.deploy_context}-${each.key}"
  }
}

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "basic" {
  for_each = {
    for k, v in var.functions : k => v if v.create_role
  }

  role       = aws_iam_role.this[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC execution policy (if VPC config provided)
resource "aws_iam_role_policy_attachment" "vpc" {
  for_each = {
    for k, v in var.functions : k => v if v.create_role && v.vpc_config != null
  }

  role       = aws_iam_role.this[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# X-Ray tracing policy
resource "aws_iam_role_policy_attachment" "xray" {
  for_each = {
    for k, v in var.functions : k => v if v.create_role && v.tracing_mode == "Active"
  }

  role       = aws_iam_role.this[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# Additional policy attachments
resource "aws_iam_role_policy_attachment" "additional" {
  for_each = merge([
    for fn_key, fn in var.functions : {
      for policy_idx, policy_arn in fn.policy_arns :
      "${fn_key}-${policy_idx}" => {
        role       = fn_key
        policy_arn = policy_arn
      }
    } if fn.create_role
  ]...)

  role       = aws_iam_role.this[each.value.role].name
  policy_arn = each.value.policy_arn
}

# Inline policies
resource "aws_iam_role_policy" "inline" {
  for_each = merge([
    for fn_key, fn in var.functions : {
      for policy_key, policy in fn.inline_policies :
      "${fn_key}-${policy_key}" => {
        role              = fn_key
        policy_name       = policy_key
        policy_statements = policy.policy_statements
      }
    } if fn.create_role
  ]...)

  name = each.value.policy_name
  role = aws_iam_role.this[each.value.role].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for stmt in each.value.policy_statements : {
        Effect   = stmt.effect
        Action   = stmt.actions
        Resource = stmt.resources
      }
    ]
  })
}
