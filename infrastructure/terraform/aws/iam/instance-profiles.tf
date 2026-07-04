# Instance Profiles (for EC2)
resource "aws_iam_instance_profile" "this" {
  for_each = var.instance_profiles

  name = each.key
  path = each.value.path
  role = aws_iam_role.this[each.value.role_key].name

  tags = {
    Name = each.key
  }
}
