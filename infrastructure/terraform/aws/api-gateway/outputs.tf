
# API Gateway
output "api_id" {
  value       = var.api_type == "REST" ? aws_api_gateway_rest_api.this.id : aws_apigatewayv2_api.this.id
  description = "API Gateway ID"
}

output "api_arn" {
  value       = var.api_type == "REST" ? aws_api_gateway_rest_api.this.arn : aws_apigatewayv2_api.this.arn
  description = "API Gateway ARN"
}

output "api_execution_arn" {
  value       = var.api_type == "REST" ? aws_api_gateway_rest_api.this.execution_arn : aws_apigatewayv2_api.this.execution_arn
  description = "API Gateway execution ARN"
}

# Endpoint URLs
output "api_endpoint" {
  value = var.api_type == "REST" ? (
    var.create_custom_domain ? "https://${var.domain_name}${var.base_path != "" ? "/${var.base_path}" : ""}" : aws_api_gateway_stage.this.invoke_url
    ) : (
    var.create_custom_domain ? "https://${var.domain_name}${var.base_path != "" ? "/${var.base_path}" : ""}" : aws_apigatewayv2_stage.this.invoke_url
  )
  description = "API Gateway endpoint URL"
}

output "execute_api_endpoint" {
  value = var.api_type == "REST" ? (
    "https://${aws_api_gateway_rest_api.this.id}.execute-api.${data.aws_region.current.region}.amazonaws.com/${var.stage_name}"
    ) : (
    aws_apigatewayv2_api.this.api_endpoint
  )
  description = "Default execute-api endpoint URL"
}

# Stage
output "stage_name" {
  value       = var.stage_name
  description = "API Gateway stage name"
}

output "stage_arn" {
  value       = var.api_type == "REST" ? aws_api_gateway_stage.this.arn : aws_apigatewayv2_stage.this.arn
  description = "API Gateway stage ARN"
}

# Custom Domain
output "custom_domain_name" {
  value       = var.create_custom_domain ? var.domain_name : null
  description = "Custom domain name"
}

output "custom_domain_cloudfront_domain_name" {
  value = var.create_custom_domain && var.api_type == "REST" && var.endpoint_type == "EDGE" ? (
    aws_api_gateway_domain_name.rest.cloudfront_domain_name
  ) : null
  description = "CloudFront domain name for EDGE endpoint"
}

output "custom_domain_regional_domain_name" {
  value = var.create_custom_domain ? (
    var.api_type == "REST" && var.endpoint_type == "REGIONAL" ?
    aws_api_gateway_domain_name.rest.regional_domain_name :
    var.api_type == "HTTP" ?
    aws_apigatewayv2_domain_name.http.domain_name_configuration[0].target_domain_name :
    null
  ) : null
  description = "Regional domain name for REGIONAL endpoint"
}

output "custom_domain_hosted_zone_id" {
  value = var.create_custom_domain ? (
    var.api_type == "REST" && var.endpoint_type == "REGIONAL" ?
    aws_api_gateway_domain_name.rest.regional_zone_id :
    var.api_type == "REST" && var.endpoint_type == "EDGE" ?
    aws_api_gateway_domain_name.rest.cloudfront_zone_id :
    var.api_type == "HTTP" ?
    aws_apigatewayv2_domain_name.http.domain_name_configuration[0].hosted_zone_id :
    null
  ) : null
  description = "Hosted zone ID for the custom domain"
}

# API Keys
output "api_key_ids" {
  value       = { for k, v in aws_api_gateway_api_key.this : k => v.id }
  description = "Map of API key IDs"
}

output "api_key_values" {
  value       = { for k, v in aws_api_gateway_api_key.this : k => v.value }
  description = "Map of API key values"
  sensitive   = true
}

# Usage Plans
output "usage_plan_ids" {
  value       = { for k, v in aws_api_gateway_usage_plan.this : k => v.id }
  description = "Map of usage plan IDs"
}

output "cognito_authorizer_ids" {
  value = var.api_type == "REST" ? (
    { for k, v in aws_api_gateway_authorizer.cognito : k => v.id }
    ) : (
    { for k, v in aws_apigatewayv2_authorizer.cognito : k => v.id }
  )
  description = "Map of Cognito authorizer IDs"
}

# VPC Link
output "vpc_link_id" {
  value = var.create_vpc_link ? (
    var.api_type == "HTTP" ?
    aws_apigatewayv2_vpc_link.this.id :
    aws_api_gateway_vpc_link.this.id
  ) : null
  description = "VPC Link ID"
}

# CloudWatch Log Groups
output "access_log_group_name" {
  value       = var.enable_access_logging ? aws_cloudwatch_log_group.access_logs.name : null
  description = "CloudWatch log group name for access logs"
}

output "access_log_group_arn" {
  value       = var.enable_access_logging ? aws_cloudwatch_log_group.access_logs.arn : null
  description = "CloudWatch log group ARN for access logs"
}
