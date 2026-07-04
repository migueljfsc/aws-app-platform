output "cluster_id" {
  value       = var.create_cluster ? aws_ecs_cluster.this.id : data.aws_ecs_cluster.this.id
  description = "ECS cluster ID"
}

output "cluster_name" {
  value       = local.cluster_name
  description = "ECS cluster name"
}

output "service_id" {
  value       = aws_ecs_service.this.id
  description = "ECS service ID"
}

output "service_name" {
  value       = aws_ecs_service.this.name
  description = "ECS service name"
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "ECS task definition ARN"
}

output "alb_dns_name" {
  value       = data.aws_lb.this.dns_name
  description = "ALB DNS name"
}

output "alb_arn" {
  value       = data.aws_lb.this.arn
  description = "ALB ARN"
}

output "alb_zone_id" {
  value       = data.aws_lb.this.zone_id
  description = "ALB zone ID for Route53"
}

output "target_group_arns" {
  description = "Map of target group ARNs keyed by target group name"
  value = {
    for k, tg in aws_lb_target_group.this :
    k => tg.arn
  }
}

output "task_role_arn" {
  value       = aws_iam_role.this.arn
  description = "ECS task role ARN"
}

# ==============================================================================
# CLOUDWATCH OUTPUTS
# ==============================================================================
output "cloudwatch_log_group_name" {
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.this.name : null
  description = "CloudWatch log group name"
}

output "cloudwatch_log_group_arn" {
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.this.arn : null
  description = "CloudWatch log group ARN"
}

output "cloudwatch_cpu_alarm_arn" {
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.cpu_high.arn : null
  description = "CloudWatch CPU high alarm ARN"
}

output "cloudwatch_memory_alarm_arn" {
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.memory_high.arn : null
  description = "CloudWatch memory high alarm ARN"
}
