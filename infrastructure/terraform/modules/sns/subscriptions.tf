# Email Subscriptions
resource "aws_sns_topic_subscription" "email" {
  for_each = var.email_subscriptions

  topic_arn                       = aws_sns_topic.this.arn
  protocol                        = "email"
  endpoint                        = each.value.endpoint
  raw_message_delivery            = each.value.raw_message_delivery
  filter_policy                   = each.value.filter_policy != "" ? each.value.filter_policy : null
  filter_policy_scope             = each.value.filter_policy != "" ? each.value.filter_policy_scope : null
  redrive_policy                  = each.value.redrive_policy != "" ? each.value.redrive_policy : null
  delivery_policy                 = each.value.delivery_policy != "" ? each.value.delivery_policy : null
  confirmation_timeout_in_minutes = each.value.confirmation_timeout_in_minutes
}

# SMS Subscriptions
resource "aws_sns_topic_subscription" "sms" {
  for_each = var.sms_subscriptions

  topic_arn           = aws_sns_topic.this.arn
  protocol            = "sms"
  endpoint            = each.value.endpoint
  filter_policy       = each.value.filter_policy != "" ? each.value.filter_policy : null
  filter_policy_scope = each.value.filter_policy != "" ? each.value.filter_policy_scope : null
  redrive_policy      = each.value.redrive_policy != "" ? each.value.redrive_policy : null
  delivery_policy     = each.value.delivery_policy != "" ? each.value.delivery_policy : null
}

# Lambda Subscriptions
resource "aws_sns_topic_subscription" "lambda" {
  for_each = var.lambda_subscriptions

  topic_arn            = aws_sns_topic.this.arn
  protocol             = "lambda"
  endpoint             = each.value.endpoint
  raw_message_delivery = each.value.raw_message_delivery
  filter_policy        = each.value.filter_policy != "" ? each.value.filter_policy : null
  filter_policy_scope  = each.value.filter_policy != "" ? each.value.filter_policy_scope : null
  redrive_policy       = each.value.redrive_policy != "" ? each.value.redrive_policy : null
  delivery_policy      = each.value.delivery_policy != "" ? each.value.delivery_policy : null
}

# SQS Subscriptions
resource "aws_sns_topic_subscription" "sqs" {
  for_each = var.sqs_subscriptions

  topic_arn            = aws_sns_topic.this.arn
  protocol             = "sqs"
  endpoint             = each.value.endpoint
  raw_message_delivery = each.value.raw_message_delivery
  filter_policy        = each.value.filter_policy != "" ? each.value.filter_policy : null
  filter_policy_scope  = each.value.filter_policy != "" ? each.value.filter_policy_scope : null
  redrive_policy       = each.value.redrive_policy != "" ? each.value.redrive_policy : null
}

# HTTP/HTTPS Subscriptions
resource "aws_sns_topic_subscription" "http" {
  for_each = var.http_subscriptions

  topic_arn                       = aws_sns_topic.this.arn
  protocol                        = startswith(each.value.endpoint, "https://") ? "https" : "http"
  endpoint                        = each.value.endpoint
  raw_message_delivery            = each.value.raw_message_delivery
  filter_policy                   = each.value.filter_policy != "" ? each.value.filter_policy : null
  filter_policy_scope             = each.value.filter_policy != "" ? each.value.filter_policy_scope : null
  redrive_policy                  = each.value.redrive_policy != "" ? each.value.redrive_policy : null
  delivery_policy                 = each.value.delivery_policy != "" ? each.value.delivery_policy : null
  confirmation_timeout_in_minutes = each.value.confirmation_timeout_in_minutes
}

# Kinesis Firehose Subscriptions
resource "aws_sns_topic_subscription" "firehose" {
  for_each = var.firehose_subscriptions

  topic_arn             = aws_sns_topic.this.arn
  protocol              = "firehose"
  endpoint              = each.value.endpoint
  subscription_role_arn = each.value.subscription_role_arn
  raw_message_delivery  = each.value.raw_message_delivery
  filter_policy         = each.value.filter_policy != "" ? each.value.filter_policy : null
  filter_policy_scope   = each.value.filter_policy != "" ? each.value.filter_policy_scope : null
  redrive_policy        = each.value.redrive_policy != "" ? each.value.redrive_policy : null
}
