# ==============================================================================
# CLOUDWATCH METRIC ALARMS
# ==============================================================================

resource "aws_cloudwatch_metric_alarm" "elb_5xx" {
  alarm_name          = "${var.service_name}-${module.aws_registry.deploy_context}-alb-5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_alarm_evaluation_periods
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.cloudwatch_alarm_period
  statistic           = "Sum"
  threshold           = var.cloudwatch_5xx_threshold
  alarm_description   = "ALB 5XX error count is above ${var.cloudwatch_5xx_threshold}"
  alarm_actions       = [data.aws_sns_topic.critical.arn]
  ok_actions          = [data.aws_sns_topic.critical.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
  }

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-alb-5xx-high"
  }

  lifecycle {
    enabled = var.enable_cloudwatch_alarms
  }
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.service_name}-${module.aws_registry.deploy_context}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cloudwatch_alarm_evaluation_periods
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.cloudwatch_alarm_period
  statistic           = "Maximum"
  threshold           = var.cloudwatch_unhealthy_hosts_threshold
  alarm_description   = "ALB has ${var.cloudwatch_unhealthy_hosts_threshold} or more unhealthy hosts"
  alarm_actions       = [data.aws_sns_topic.critical.arn]
  ok_actions          = [data.aws_sns_topic.critical.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
  }

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-alb-unhealthy-hosts"
  }

  lifecycle {
    enabled = var.enable_cloudwatch_alarms
  }
}

resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  alarm_name          = "${var.service_name}-${module.aws_registry.deploy_context}-alb-target-5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_alarm_evaluation_periods
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.cloudwatch_alarm_period
  statistic           = "Sum"
  threshold           = var.cloudwatch_target_5xx_threshold
  alarm_description   = "Target 5XX error count is above ${var.cloudwatch_target_5xx_threshold}"
  alarm_actions       = [data.aws_sns_topic.warning.arn]
  ok_actions          = [data.aws_sns_topic.warning.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
  }

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-alb-target-5xx-high"
  }

  lifecycle {
    enabled = var.enable_cloudwatch_alarms
  }
}

resource "aws_cloudwatch_metric_alarm" "latency_high" {
  alarm_name          = "${var.service_name}-${module.aws_registry.deploy_context}-alb-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_alarm_evaluation_periods
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = var.cloudwatch_alarm_period
  statistic           = "Average"
  threshold           = var.cloudwatch_latency_threshold
  alarm_description   = "ALB target response time is above ${var.cloudwatch_latency_threshold}s"
  alarm_actions       = [data.aws_sns_topic.warning.arn]
  ok_actions          = [data.aws_sns_topic.warning.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
  }

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-alb-latency-high"
  }

  lifecycle {
    enabled = var.enable_cloudwatch_alarms
  }
}
