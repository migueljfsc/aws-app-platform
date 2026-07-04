# Lambda Aliases
resource "aws_lambda_alias" "this" {
  for_each = merge([
    for fn_key, fn in var.functions : {
      for alias_key, alias in fn.aliases :
      "${fn_key}-${alias_key}" => {
        function_key     = fn_key
        alias_name       = alias_key
        description      = alias.description
        function_version = alias.function_version
        routing_config   = alias.routing_config
      }
    }
  ]...)

  name             = each.value.alias_name
  description      = each.value.description
  function_name    = aws_lambda_function.this[each.value.function_key].function_name
  function_version = each.value.function_version

  dynamic "routing_config" {
    for_each = each.value.routing_config != null ? [each.value.routing_config] : []
    content {
      additional_version_weights = routing_config.value.additional_version_weights
    }
  }
}
