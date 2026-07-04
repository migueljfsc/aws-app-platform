# SNS Topic
resource "aws_sns_topic" "this" {
  name         = local.topic_name
  display_name = var.display_name != "" ? var.display_name : local.topic_name

  # FIFO configuration
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.fifo_topic ? var.content_based_deduplication : null

  # Encryption
  kms_master_key_id = var.kms_master_key_id != "" ? var.kms_master_key_id : null

  # Signature and tracing
  signature_version = var.signature_version
  tracing_config    = var.tracing_config

  # Delivery policy
  delivery_policy = var.delivery_policy != "" ? var.delivery_policy : null

  # Delivery feedback (HTTP)
  http_success_feedback_role_arn    = var.http_success_feedback_role_arn != "" ? var.http_success_feedback_role_arn : null
  http_success_feedback_sample_rate = var.http_success_feedback_role_arn != "" ? var.http_success_feedback_sample_rate : null
  http_failure_feedback_role_arn    = var.http_failure_feedback_role_arn != "" ? var.http_failure_feedback_role_arn : null

  # Delivery feedback (Lambda)
  lambda_success_feedback_role_arn    = var.lambda_success_feedback_role_arn != "" ? var.lambda_success_feedback_role_arn : null
  lambda_success_feedback_sample_rate = var.lambda_success_feedback_role_arn != "" ? var.lambda_success_feedback_sample_rate : null
  lambda_failure_feedback_role_arn    = var.lambda_failure_feedback_role_arn != "" ? var.lambda_failure_feedback_role_arn : null

  # Delivery feedback (SQS)
  sqs_success_feedback_role_arn    = var.sqs_success_feedback_role_arn != "" ? var.sqs_success_feedback_role_arn : null
  sqs_success_feedback_sample_rate = var.sqs_success_feedback_role_arn != "" ? var.sqs_success_feedback_sample_rate : null
  sqs_failure_feedback_role_arn    = var.sqs_failure_feedback_role_arn != "" ? var.sqs_failure_feedback_role_arn : null

  # Delivery feedback (Firehose)
  firehose_success_feedback_role_arn    = var.firehose_success_feedback_role_arn != "" ? var.firehose_success_feedback_role_arn : null
  firehose_success_feedback_sample_rate = var.firehose_success_feedback_role_arn != "" ? var.firehose_success_feedback_sample_rate : null
  firehose_failure_feedback_role_arn    = var.firehose_failure_feedback_role_arn != "" ? var.firehose_failure_feedback_role_arn : null

  # Delivery feedback (Mobile push)
  application_success_feedback_role_arn    = var.application_success_feedback_role_arn != "" ? var.application_success_feedback_role_arn : null
  application_success_feedback_sample_rate = var.application_success_feedback_role_arn != "" ? var.application_success_feedback_sample_rate : null
  application_failure_feedback_role_arn    = var.application_failure_feedback_role_arn != "" ? var.application_failure_feedback_role_arn : null

  tags = {
    Name = local.topic_name
  }
}

# Data Protection Policy
resource "aws_sns_topic_data_protection_policy" "this" {
  count = var.data_protection_policy != "" ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = var.data_protection_policy
}
