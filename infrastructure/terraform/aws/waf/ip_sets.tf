# IP Sets
resource "aws_wafv2_ip_set" "this" {
  for_each = var.ip_sets

  name               = replace("${var.service_name}-${each.key}-${module.aws_registry.deploy_context}", "_", "-")
  description        = each.value.description != "" ? each.value.description : "IP set for ${var.service_name}"
  scope              = each.value.scope
  ip_address_version = each.value.ip_address_version
  addresses          = each.value.addresses

  tags = {
    Name = "${var.service_name}-${each.key}-${module.aws_registry.deploy_context}"
  }
}
