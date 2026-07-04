# Topic
output "topic_arn" {
  value       = aws_sns_topic.this.arn
  description = "SNS topic ARN"
}

output "topic_id" {
  value       = aws_sns_topic.this.id
  description = "SNS topic ID"
}

output "topic_name" {
  value       = aws_sns_topic.this.name
  description = "SNS topic name"
}

output "topic_owner" {
  value       = aws_sns_topic.this.owner
  description = "AWS account ID that owns the SNS topic"
}

# Subscriptions
output "email_subscription_arns" {
  value       = { for k, v in aws_sns_topic_subscription.email : k => v.arn }
  description = "Map of email subscription ARNs"
}

output "sms_subscription_arns" {
  value       = { for k, v in aws_sns_topic_subscription.sms : k => v.arn }
  description = "Map of SMS subscription ARNs"
}

output "lambda_subscription_arns" {
  value       = { for k, v in aws_sns_topic_subscription.lambda : k => v.arn }
  description = "Map of Lambda subscription ARNs"
}

output "sqs_subscription_arns" {
  value       = { for k, v in aws_sns_topic_subscription.sqs : k => v.arn }
  description = "Map of SQS subscription ARNs"
}

output "http_subscription_arns" {
  value       = { for k, v in aws_sns_topic_subscription.http : k => v.arn }
  description = "Map of HTTP subscription ARNs"
}

output "firehose_subscription_arns" {
  value       = { for k, v in aws_sns_topic_subscription.firehose : k => v.arn }
  description = "Map of Firehose subscription ARNs"
}

# All subscriptions
output "all_subscription_arns" {
  value = merge(
    { for k, v in aws_sns_topic_subscription.email : "email-${k}" => v.arn },
    { for k, v in aws_sns_topic_subscription.sms : "sms-${k}" => v.arn },
    { for k, v in aws_sns_topic_subscription.lambda : "lambda-${k}" => v.arn },
    { for k, v in aws_sns_topic_subscription.sqs : "sqs-${k}" => v.arn },
    { for k, v in aws_sns_topic_subscription.http : "http-${k}" => v.arn },
    { for k, v in aws_sns_topic_subscription.firehose : "firehose-${k}" => v.arn }
  )
  description = "Map of all subscription ARNs with protocol prefixes"
}
