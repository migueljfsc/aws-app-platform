# Lambda Functions
output "function_arns" {
  value       = { for k, v in aws_lambda_function.this : k => v.arn }
  description = "Map of Lambda function ARNs"
}

output "function_names" {
  value       = { for k, v in aws_lambda_function.this : k => v.function_name }
  description = "Map of Lambda function names"
}

output "function_qualified_arns" {
  value       = { for k, v in aws_lambda_function.this : k => v.qualified_arn }
  description = "Map of Lambda function qualified ARNs (with version)"
}

output "function_versions" {
  value       = { for k, v in aws_lambda_function.this : k => v.version }
  description = "Map of Lambda function versions"
}

output "function_invoke_arns" {
  value       = { for k, v in aws_lambda_function.this : k => v.invoke_arn }
  description = "Map of Lambda function invoke ARNs"
}

# IAM Roles
output "role_arns" {
  value       = { for k, v in aws_iam_role.this : k => v.arn }
  description = "Map of IAM role ARNs"
}

output "role_names" {
  value       = { for k, v in aws_iam_role.this : k => v.name }
  description = "Map of IAM role names"
}

# CloudWatch Log Groups
output "log_group_names" {
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
  description = "Map of CloudWatch log group names"
}

output "log_group_arns" {
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.arn }
  description = "Map of CloudWatch log group ARNs"
}

# Aliases
output "alias_arns" {
  value = {
    for k, v in aws_lambda_alias.this :
    k => v.arn
  }
  description = "Map of Lambda alias ARNs"
}

# API Gateway Integration
output "api_gateway_route_ids" {
  value = merge(
    { for k, v in aws_apigatewayv2_route.this : k => v.id },
    { for k, v in aws_api_gateway_method.this : k => v.id }
  )
  description = "Map of API Gateway route/method IDs"
}

output "api_gateway_integration_ids" {
  value = merge(
    { for k, v in aws_apigatewayv2_integration.this : k => v.id },
    { for k, v in aws_api_gateway_integration.this : k => v.id }
  )
  description = "Map of API Gateway integration IDs"
}

# Event Source Mappings
output "event_source_mapping_uuids" {
  value       = { for k, v in aws_lambda_event_source_mapping.this : k => v.uuid }
  description = "Map of event source mapping UUIDs"
}
