data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# REST APIs
data "aws_api_gateway_rest_api" "this" {
  for_each = {
    for fn_key, fn in var.functions :
    fn_key => fn
    if fn.api_gateway != null
    && fn.api_gateway.api_type == "REST"
    && try(fn.api_gateway.api_id, "") == ""
    && try(fn.api_gateway.api_name, "") != ""
  }

  name = each.value.api_gateway.api_name
}

# HTTP APIs
data "aws_apigatewayv2_apis" "http" {
  for_each = {
    for fn_key, fn in var.functions :
    fn_key => fn
    if fn.api_gateway != null
    && fn.api_gateway.api_type == "HTTP"
    && try(fn.api_gateway.api_id, "") == ""
    && try(fn.api_gateway.api_name, "") != ""
  }

  name          = each.value.api_gateway.api_name
  protocol_type = "HTTP"
}
