locals {
  rest_api_ids = {
    for fn_key, fn in var.functions :
    fn_key => (
      try(fn.api_gateway.api_id, "") != "" ?
      fn.api_gateway.api_id :
      data.aws_api_gateway_rest_api.this[fn_key].id
    )
    if fn.api_gateway != null && fn.api_gateway.api_type == "REST"
  }

  http_api_ids = {
    for fn_key, fn in var.functions :
    fn_key => (
      try(fn.api_gateway.api_id, "") != "" ?
      fn.api_gateway.api_id :
      try(one(data.aws_apigatewayv2_apis.http[fn_key].ids), null)
    )
    if fn.api_gateway != null && try(fn.api_gateway.api_type, "") == "HTTP"
  }
}
