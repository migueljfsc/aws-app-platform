# SNS Topic with SQS fan-out
module "sns_order_events" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "sqs"

  display_name = "Order Events"

  # Fan out to multiple SQS queues
  sqs_subscriptions = {
    orders = {
      endpoint             = "queue-arn"
      raw_message_delivery = true
    }
    inventory = {
      endpoint             = "queue-arn"
      raw_message_delivery = true
      # Only receive inventory-related events
      filter_policy = jsonencode({
        event_type = ["order_created", "order_cancelled"]
      })
    }
    notifications = {
      endpoint             = "queue-arn"
      raw_message_delivery = false
      # Only receive high-value orders
      filter_policy = jsonencode({
        order_value = [{ numeric = [">", 100] }]
      })
    }
  }
}
