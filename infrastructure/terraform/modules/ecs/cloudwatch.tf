# ==============================================================================
# CLOUDWATCH LOG GROUP
# ==============================================================================
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.service_name}-${var.deploy_context}"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = {
    Name = "/ecs/${var.service_name}-${var.deploy_context}"
  }

  lifecycle {
    enabled = var.enable_cloudwatch_logs
  }
}

# ==============================================================================
# CLOUDWATCH METRIC ALARMS
# ==============================================================================
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.service_name}-${var.deploy_context}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_cpu_alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cloudwatch_cpu_alarm_period
  statistic           = "Average"
  threshold           = var.cloudwatch_cpu_alarm_threshold
  alarm_description   = "ECS service CPU utilization is above ${var.cloudwatch_cpu_alarm_threshold}%"
  alarm_actions       = var.cloudwatch_alarm_actions
  ok_actions          = var.cloudwatch_ok_actions

  dimensions = {
    ClusterName = local.cluster_name
    ServiceName = aws_ecs_service.this.name
  }

  tags = {
    Name = "${var.service_name}-${var.deploy_context}-cpu-high"
  }

  lifecycle {
    enabled = var.enable_cloudwatch_alarms
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.service_name}-${var.deploy_context}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_memory_alarm_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.cloudwatch_memory_alarm_period
  statistic           = "Average"
  threshold           = var.cloudwatch_memory_alarm_threshold
  alarm_description   = "ECS service memory utilization is above ${var.cloudwatch_memory_alarm_threshold}%"
  alarm_actions       = var.cloudwatch_alarm_actions
  ok_actions          = var.cloudwatch_ok_actions

  dimensions = {
    ClusterName = local.cluster_name
    ServiceName = aws_ecs_service.this.name
  }

  tags = {
    Name = "${var.service_name}-${var.deploy_context}-memory-high"
  }

  lifecycle {
    enabled = var.enable_cloudwatch_alarms
  }
}
