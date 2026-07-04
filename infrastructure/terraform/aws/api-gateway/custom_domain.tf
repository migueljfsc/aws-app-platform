# Custom Domain Name (REST API)
resource "aws_api_gateway_domain_name" "rest" {
  domain_name              = var.domain_name
  regional_certificate_arn = var.endpoint_type == "REGIONAL" ? local.certificate_arn : null
  certificate_arn          = var.endpoint_type == "EDGE" ? local.certificate_arn : null
  security_policy          = var.security_policy

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = {
    Name = var.domain_name
  }

  lifecycle {
    enabled = var.api_type == "REST" && var.create_custom_domain
  }
}

# Base Path Mapping (REST API)
resource "aws_api_gateway_base_path_mapping" "rest" {
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.rest.domain_name
  base_path   = var.base_path

  lifecycle {
    enabled = var.api_type == "REST" && var.create_custom_domain
  }
}

# Custom Domain Name (HTTP API)
resource "aws_apigatewayv2_domain_name" "http" {
  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = local.certificate_arn
    endpoint_type   = var.endpoint_type
    security_policy = var.security_policy
  }

  tags = {
    Name = var.domain_name
  }

  lifecycle {
    enabled = var.api_type == "HTTP" && var.create_custom_domain
  }
}

# API Mapping (HTTP API)
resource "aws_apigatewayv2_api_mapping" "http" {
  api_id          = aws_apigatewayv2_api.this.id
  domain_name     = aws_apigatewayv2_domain_name.http.id
  stage           = aws_apigatewayv2_stage.this.id
  api_mapping_key = var.base_path != "" ? var.base_path : null

  lifecycle {
    enabled = var.api_type == "HTTP" && var.create_custom_domain
  }
}
