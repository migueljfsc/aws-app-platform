output "budget_ids" {
  value       = { for k, v in aws_budgets_budget.this : k => v.id }
  description = "Map of budget key to budget ID"
}

output "budget_names" {
  value       = { for k, v in aws_budgets_budget.this : k => v.name }
  description = "Map of budget key to budget name"
}

output "sns_topic_arn" {
  value       = module.sns.topic_arn
  description = "ARN of the SNS topic for budget alerts"
}

output "anomaly_monitor_arn" {
  value       = try(aws_ce_anomaly_monitor.this.arn, null)
  description = "ARN of the AWS Cost Anomaly Monitor (if enabled)"
}

output "anomaly_subscription_arn" {
  value       = try(aws_ce_anomaly_subscription.this.arn, null)
  description = "ARN of the AWS Cost Anomaly Subscription (if enabled)"
}
