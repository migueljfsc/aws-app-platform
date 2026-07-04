# Topic Policy
resource "aws_sns_topic_policy" "this" {
  count = var.topic_policy != "" || local.create_default_policy ? 1 : 0

  arn = aws_sns_topic.this.arn

  policy = var.topic_policy != "" ? var.topic_policy : jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      # Allow cross-account publishing
      length(var.allow_publish_from_accounts) > 0 ? [
        {
          Sid    = "AllowCrossAccountPublish"
          Effect = "Allow"
          Principal = {
            AWS = [for account_id in var.allow_publish_from_accounts : "arn:aws:iam::${account_id}:root"]
          }
          Action   = "SNS:Publish"
          Resource = aws_sns_topic.this.arn
        }
      ] : [],
      # Allow service publishing
      length(var.allow_publish_from_services) > 0 ? [
        {
          Sid    = "AllowServicePublish"
          Effect = "Allow"
          Principal = {
            Service = var.allow_publish_from_services
          }
          Action   = "SNS:Publish"
          Resource = aws_sns_topic.this.arn
        }
      ] : []
    )
  })
}
