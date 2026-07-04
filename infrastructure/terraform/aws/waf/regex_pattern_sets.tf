# Regex Pattern Sets
resource "aws_wafv2_regex_pattern_set" "this" {
  for_each = var.regex_pattern_sets

  name        = "${var.service_name}-${each.key}-${module.aws_registry.deploy_context}"
  description = each.value.description != "" ? each.value.description : "Regex pattern set for ${var.service_name}-${each.key}-${module.aws_registry.deploy_context}"
  scope       = each.value.scope

  dynamic "regular_expression" {
    for_each = each.value.patterns
    content {
      regex_string = regular_expression.value.regex
    }
  }

  tags = {
    Name = "${var.service_name}-${each.key}-${module.aws_registry.deploy_context}"
  }
}
