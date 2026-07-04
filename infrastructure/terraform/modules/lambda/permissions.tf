# Lambda Permissions
resource "aws_lambda_permission" "this" {
  for_each = merge([
    for fn_key, fn in var.functions : {
      for perm_key, perm in fn.permissions :
      "${fn_key}-${perm_key}" => {
        function_name  = aws_lambda_function.this[fn_key].function_name
        principal      = perm.principal
        source_arn     = perm.source_arn
        source_account = perm.source_account
      }
    }
  ]...)

  statement_id   = each.key
  action         = "lambda:InvokeFunction"
  function_name  = each.value.function_name
  principal      = each.value.principal
  source_arn     = each.value.source_arn != "" ? each.value.source_arn : null
  source_account = each.value.source_account != "" ? each.value.source_account : null
}
