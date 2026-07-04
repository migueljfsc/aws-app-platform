module "sns_webhooks" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "webhooks"

  display_name = "Webhook Notifications"

  http_subscriptions = {
    slack = {
      endpoint = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
    }

    internal_api = {
      endpoint = "https://api.example.com/webhooks/events"

      # Custom delivery policy for retries
      delivery_policy = jsonencode({
        healthyRetryPolicy = {
          minDelayTarget     = 1
          maxDelayTarget     = 60
          numRetries         = 10
          numNoDelayRetries  = 0
          numMinDelayRetries = 3
          numMaxDelayRetries = 7
          backoffFunction    = "exponential"
        }
      })
    }

    pagerduty = {
      endpoint = "https://events.pagerduty.com/integration/YOUR_KEY/enqueue"

      # Only send critical alerts to PagerDuty
      filter_policy = jsonencode({
        severity = ["critical", "high"]
      })
    }
  }
}
