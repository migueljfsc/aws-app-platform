# Service-Linked Roles
resource "aws_iam_service_linked_role" "this" {
  for_each = var.service_linked_roles

  aws_service_name = each.value.aws_service_name
  description      = each.value.description != "" ? each.value.description : null
  custom_suffix    = each.value.custom_suffix != "" ? each.value.custom_suffix : null

  tags = {
    Name = each.key
  }
}
