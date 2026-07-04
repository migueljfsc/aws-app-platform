locals {
  topic_name = var.fifo_topic ? "${var.service_name}-${var.deploy_context}.fifo" : "${var.service_name}-${var.deploy_context}"

  # Create default policy if none provided
  create_default_policy = var.topic_policy == "" && (
    length(var.allow_publish_from_accounts) > 0 ||
    length(var.allow_publish_from_services) > 0
  )
}
