# Customer Managed Policies
resource "aws_iam_policy" "this" {
  for_each = var.policies

  name        = each.key
  path        = each.value.path
  description = each.value.description

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
            for cond in stmt.conditions :
            cond.test => {
              (cond.variable) = cond.values
            }
          }
        } : {}
      )
    ]
  })

  tags = {
    Name = each.key
  }
}
