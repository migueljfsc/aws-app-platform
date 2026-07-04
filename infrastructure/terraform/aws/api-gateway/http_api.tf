# HTTP API Gateway
resource "aws_apigatewayv2_api" "this" {
  name          = local.api_name
  description   = var.description != "" ? var.description : "HTTP API for ${var.service_name}"
  protocol_type = var.protocol_type

  disable_execute_api_endpoint = var.disable_execute_api_endpoint

  dynamic "cors_configuration" {
    for_each = var.cors_configuration != null ? [var.cors_configuration] : []
    content {
      allow_origins     = cors_configuration.value.allow_origins
      allow_methods     = cors_configuration.value.allow_methods
      allow_headers     = cors_configuration.value.allow_headers
      expose_headers    = cors_configuration.value.expose_headers
      max_age           = cors_configuration.value.max_age
      allow_credentials = cors_configuration.value.allow_credentials
    }
  }

  tags = {
    Name = local.api_name
  }

  lifecycle {
    enabled = var.api_type == "HTTP"
  }
}

# Cognito Authorizers (HTTP API)
resource "aws_apigatewayv2_authorizer" "cognito" {
  for_each = var.api_type == "HTTP" ? var.cognito_authorizers : {}

  api_id           = aws_apigatewayv2_api.this.id
  authorizer_type  = "JWT"
  identity_sources = each.value.identity_sources
  name             = each.key

  jwt_configuration {
    audience = each.value.audience
    issuer   = each.value.issuer
  }
}

# Stage (HTTP API)
resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  description = var.stage_description != "" ? var.stage_description : "${var.stage_name} stage"
  auto_deploy = var.auto_deploy

  stage_variables = var.stage_variables

  dynamic "access_log_settings" {
    for_each = var.enable_access_logging ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.access_logs.arn
      format          = var.access_log_format != "" ? var.access_log_format : local.default_access_log_format
    }
  }

  default_route_settings {
    throttling_burst_limit   = var.throttle_burst_limit
    throttling_rate_limit    = var.throttle_rate_limit
    detailed_metrics_enabled = var.enable_metrics
  }

  tags = {
    Name = "${local.api_name}-${var.stage_name}"
  }

  lifecycle {
    enabled = var.api_type == "HTTP"
  }
}
