resource "aws_ce_anomaly_monitor" "this" {
  name              = "${var.service_name}-${module.aws_registry.deploy_context}-aws-services"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-anomaly-monitor"
  }

  lifecycle {
    enabled = var.enable_anomaly_detection
  }
}

resource "aws_ce_anomaly_subscription" "this" {
  name      = "${var.service_name}-${module.aws_registry.deploy_context}-anomaly-subscription"
  frequency = "IMMEDIATE"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.this.arn
  ]

  subscriber {
    type    = "SNS"
    address = module.sns.topic_arn
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
      values        = [tostring(var.anomaly_threshold_percentage)]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-anomaly-subscription"
  }

  lifecycle {
    enabled = var.enable_anomaly_detection
  }
}
