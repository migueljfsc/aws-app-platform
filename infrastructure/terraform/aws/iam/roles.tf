# IAM Roles
resource "aws_iam_role" "this" {
  for_each = var.roles

  name                  = each.key
  path                  = each.value.path
  description           = each.value.description
  max_session_duration  = each.value.max_session_duration
  force_detach_policies = each.value.force_detach_policies
  permissions_boundary  = each.value.permissions_boundary != "" ? each.value.permissions_boundary : null

  assume_role_policy = each.value.assume_role_policy_json != "" ? each.value.assume_role_policy_json : (
    each.value.assume_role_policy != null ? jsonencode({
      Version = "2012-10-17"
      Statement = [
        merge(
          {
            Effect = "Allow"
            Principal = {
              for principal in each.value.assume_role_policy.principals :
              principal.type => principal.identifiers
            }
            Action = each.value.assume_role_policy.action != "" ? each.value.assume_role_policy.action : "sts:AssumeRole"
          },
          length(each.value.assume_role_policy.conditions) > 0 ? {
            Condition = {
              for test_key in distinct([for c in each.value.assume_role_policy.conditions : c.test]) :
              test_key => {
                for cond in each.value.assume_role_policy.conditions :
                cond.variable => cond.values
                if cond.test == test_key
              }
            }
          } : {}
        )
      ]
      }) : jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
    })
  )

  tags = {
    Name = each.key
  }
}

# Role Inline Policies
resource "aws_iam_role_policy" "this" {
  for_each = var.role_policies

  name = each.key
  role = aws_iam_role.this[each.value.role_key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for stmt in each.value.policy_statements : merge(
        {
          Sid      = stmt.sid
          Effect   = stmt.effect
          Action   = stmt.actions
          Resource = stmt.resources
        },
        length(stmt.conditions) > 0 ? {
          Condition = {
            for test_key in distinct([for c in stmt.conditions : c.test]) :
            test_key => {
              for cond in stmt.conditions :
              cond.variable => cond.values
              if cond.test == test_key
            }
          }
        } : {}
      )
    ]
  })
}

# Role Managed Policy Attachments
resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.role_policy_attachments

  role       = aws_iam_role.this[each.value.role_key].name
  policy_arn = each.value.policy_arn
}
