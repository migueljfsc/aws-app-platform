output "tags" {
  value       = local.tags
  description = "Normalized Tag map"
}

output "region" {
  value       = var.region
  description = "AWS Region"
}

output "region_short" {
  value       = local.region_short
  description = "AWS Region Short"
}

output "deploy_context" {
  value       = local.deploy_context
  description = "Deploy Context"
}

output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS Account ID"
}

output "account_name" {
  value       = local.account_name
  description = "AWS Account Name"
}

output "caller_arn" {
  value       = data.aws_caller_identity.current.arn
  description = "AWS Caller ARN"
}
