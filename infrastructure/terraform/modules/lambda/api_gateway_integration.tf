# ============================================================================
# REST API Integration
# ============================================================================

# API Gateway Integration - REST API Resources
resource "aws_api_gateway_resource" "this" {
  for_each = merge([
    for fn_key, fn in var.functions : {
      for route_key, route in(fn.api_gateway != null ? fn.api_gateway.routes : {}) :
      "${fn_key}-${route_key}" => {
        api_id           = local.rest_api_ids[fn_key]
        api_type         = fn.api_gateway.api_type
        root_resource_id = fn.api_gateway.root_resource_id
        path             = route.path
      } if fn.api_gateway != null && fn.api_gateway.api_type == "REST" && route.path != "/"
    }
  ]...)

  rest_api_id = each.value.api_id
  parent_id   = each.value.root_resource_id
  path_part   = trimprefix(each.value.path, "/")
}

# API Gateway Integration - REST API Methods
resource "aws_api_gateway_method" "this" {
  for_each = merge([
    for fn_key, fn in var.functions : {
      for route_key, route in(fn.api_gateway != null ? fn.api_gateway.routes : {}) :
      "${fn_key}-${route_key}" => {
        function_key         = fn_key
        api_id               = local.rest_api_ids[fn_key]
        api_type             = fn.api_gateway.api_type
        root_resource_id     = fn.api_gateway.root_resource_id
        request_validator_id = fn.api_gateway.request_validator_id
        path                 = route.path
        http_method          = route.http_method
        authorization_type   = route.authorization_type
        authorizer_id        = route.authorizer_id
        api_key_required     = route.api_key_required
        request_parameters   = route.request_parameters
      } if fn.api_gateway != null && fn.api_gateway.api_type == "REST"
    }
  ]...)

  rest_api_id          = each.value.api_id
  resource_id          = each.value.path == "/" ? each.value.root_resource_id : aws_api_gateway_resource.this[each.key].id
  http_method          = each.value.http_method
  authorization        = each.value.authorization_type
  authorizer_id        = each.value.authorizer_id != "" ? each.value.authorizer_id : null
  api_key_required     = each.value.api_key_required
  request_parameters   = each.value.request_parameters
  request_validator_id = each.value.request_validator_id != "" ? each.value.request_validator_id : null
}

# API Gateway Integration - REST API Integrations
resource "aws_api_gateway_integration" "this" {
  for_each = merge([
    for fn_key, fn in var.functions : {
      for route_key, route in(fn.api_gateway != null ? fn.api_gateway.routes : {}) :
      "${fn_key}-${route_key}" => {
        function_key         = fn_key
        api_id               = local.rest_api_ids[fn_key]
        api_type             = fn.api_gateway.api_type
        root_resource_id     = fn.api_gateway.root_resource_id
        path                 = route.path
        http_method          = route.http_method
        timeout_milliseconds = route.timeout_milliseconds
      } if fn.api_gateway != null && fn.api_gateway.api_type == "REST"
    }
  ]...)

  rest_api_id             = each.value.api_id
  resource_id             = each.value.path == "/" ? each.value.root_resource_id : aws_api_gateway_resource.this[each.key].id
  http_method             = aws_api_gateway_method.this[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.this[each.value.function_key].arn}/invocations"
  timeout_milliseconds    = each.value.timeout_milliseconds
}

# Lambda Permissions for REST API
resource "aws_lambda_permission" "apigw_rest" {
  for_each = merge([
    for fn_key, fn in var.functions : {
      for route_key, route in(fn.api_gateway != null ? fn.api_gateway.routes : {}) :
      "${fn_key}-${route_key}" => {
        function_name = aws_lambda_function.this[fn_key].function_name
        function_arn  = aws_lambda_function.this[fn_key].arn
        api_id        = local.rest_api_ids[fn_key]
        http_method   = route.http_method
        path          = route.path
      } if fn.api_gateway != null && fn.api_gateway.api_type == "REST"
    }
  ]...)

  statement_id  = "AllowAPIGatewayInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"

  # Get execution ARN from data source
  source_arn = "arn:aws:execute-api:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:${each.value.api_id}/*/${each.value.http_method}${each.value.path}"
}

# ============================================================================
# HTTP API Integration
# ============================================================================

# HTTP API Integrations (one per Lambda function with API Gateway config)
resource "aws_apigatewayv2_integration" "this" {
  for_each = {
    for fn_key, fn in var.functions :
    fn_key => fn
    if fn.api_gateway != null && fn.api_gateway.api_type == "HTTP"
  }

  api_id           = local.http_api_ids[each.key]
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.this[each.key].arn

  integration_method = "POST"
  # Use the payload format version from the first route (they should all be the same)
  payload_format_version = try(
    values(each.value.api_gateway.routes)[0].payload_format_version,
    "2.0"
  )
  timeout_milliseconds = try(
    values(each.value.api_gateway.routes)[0].timeout_milliseconds,
    29000
  )
}

# HTTP API Routes
resource "aws_apigatewayv2_route" "this" {
  for_each = merge([
    for fn_key, fn in var.functions : {
      for route_key, route in(fn.api_gateway != null ? fn.api_gateway.routes : {}) :
      "${fn_key}-${route_key}" => {
        function_key       = fn_key
        api_id             = local.http_api_ids[fn_key]
        route_key          = "${route.http_method} ${route.path}"
        authorization_type = route.authorization_type
        authorizer_id      = route.authorizer_id
      } if fn.api_gateway != null && fn.api_gateway.api_type == "HTTP"
    }
  ]...)

  api_id    = each.value.api_id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.this[each.value.function_key].id}"

  authorization_type = each.value.authorization_type
  authorizer_id      = each.value.authorizer_id != "" ? each.value.authorizer_id : null
}

# Lambda Permissions for HTTP API
resource "aws_lambda_permission" "apigw_http" {
  for_each = {
    for fn_key, fn in var.functions :
    fn_key => fn
    if fn.api_gateway != null && fn.api_gateway.api_type == "HTTP"
  }

  statement_id  = "AllowAPIGatewayInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[each.key].function_name
  principal     = "apigateway.amazonaws.com"

  # Get execution ARN from data source
  source_arn = "arn:aws:execute-api:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:${local.http_api_ids[each.key]}/*/*"
}
