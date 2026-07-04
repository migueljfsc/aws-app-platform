# IAM Users
resource "aws_iam_user" "this" {
  for_each = var.users

  name                 = each.key
  path                 = each.value.path
  force_destroy        = each.value.force_destroy
  permissions_boundary = each.value.permissions_boundary != "" ? each.value.permissions_boundary : null

  tags = {
    Name = each.key
  }
}

# User Group Memberships
resource "aws_iam_user_group_membership" "this" {
  for_each = {
    for user_key, user in var.users :
    user_key => user if length(user.groups) > 0
  }

  user   = aws_iam_user.this[each.key].name
  groups = [for g in each.value.groups : aws_iam_group.this[g].name]
}

resource "aws_iam_user_group_membership" "existing" {
  for_each = {
    for user_key, user in var.existing_users :
    user_key => user if length(user.groups) > 0
  }

  user   = each.key # Use the key directly (existing user name)
  groups = [for g in each.value.groups : aws_iam_group.this[g].name]
}


# Access Keys
resource "aws_iam_access_key" "this" {
  for_each = var.create_user_access_keys ? var.user_access_keys : []

  user = aws_iam_user.this[each.key].name
}

# Login Profiles
resource "aws_iam_user_login_profile" "this" {
  for_each = var.create_user_login_profiles ? var.user_login_profiles : {}

  user                    = aws_iam_user.this[each.key].name
  password_length         = each.value.password_length
  password_reset_required = each.value.password_reset_required

  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required
    ]
  }
}
