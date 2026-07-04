# IAM Groups
resource "aws_iam_group" "this" {
  for_each = var.groups

  name = each.key
  path = each.value.path
}

# Group Inline Policies
resource "aws_iam_group_policy" "this" {
  for_each = var.group_policies

  name  = each.key
  group = aws_iam_group.this[each.value.group_key].name

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
}

# Group Managed Policy Attachments
resource "aws_iam_group_policy_attachment" "this" {
  for_each = var.group_policy_attachments

  group      = aws_iam_group.this[each.value.group_key].name
  policy_arn = each.value.policy_arn
}
