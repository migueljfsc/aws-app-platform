# REST API Gateway
resource "aws_api_gateway_rest_api" "this" {
  name        = local.api_name
  description = var.description != "" ? var.description : "REST API for ${var.service_name}"

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  disable_execute_api_endpoint = var.disable_execute_api_endpoint

  tags = {
    Name = local.api_name
  }

  lifecycle {
    enabled = var.api_type == "REST"
  }
}

# Request Validator (REST API)
resource "aws_api_gateway_request_validator" "this" {
  name                        = "${local.api_name}-validator"
  rest_api_id                 = aws_api_gateway_rest_api.this.id
  validate_request_body       = var.validate_request_body
  validate_request_parameters = var.validate_request_parameters

  lifecycle {
    enabled = var.api_type == "REST" && var.create_request_validator
  }
}

# Cognito Authorizers (REST API)
resource "aws_api_gateway_authorizer" "cognito" {
  for_each = var.api_type == "REST" ? var.cognito_authorizers : {}

  name          = each.key
  rest_api_id   = aws_api_gateway_rest_api.this.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = each.value.user_pool_arns
}

# Deployment (REST API)
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha256(jsonencode([
      aws_api_gateway_rest_api.this.body
    ]))
  }

  lifecycle {
    enabled               = var.api_type == "REST"
    create_before_destroy = true
  }
}

# Stage (REST API)
resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name
  description   = var.stage_description != "" ? var.stage_description : "${var.stage_name} stage"

  variables = var.stage_variables

  xray_tracing_enabled = var.enable_tracing

  dynamic "access_log_settings" {
    for_each = var.enable_access_logging ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.access_logs[0].arn
      format          = var.access_log_format != "" ? var.access_log_format : local.default_access_log_format
    }
  }

  tags = {
    Name = "${local.api_name}-${var.stage_name}"
  }

  lifecycle {
    enabled = var.api_type == "REST"
  }
}

# Method Settings (REST API)
resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = var.enable_metrics
    logging_level          = var.enable_execution_logging ? var.logging_level : "OFF"
    data_trace_enabled     = var.enable_execution_logging
    throttling_burst_limit = var.throttle_burst_limit
    throttling_rate_limit  = var.throttle_rate_limit
  }

  lifecycle {
    enabled = var.api_type == "REST"
  }
}
