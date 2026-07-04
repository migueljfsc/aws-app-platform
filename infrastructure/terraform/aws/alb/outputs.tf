output "alb_id" {
  value       = aws_lb.this.id
  description = "ALB ID"
}

output "alb_arn" {
  value       = aws_lb.this.arn
  description = "ALB ARN"
}

output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "ALB DNS name"
}

output "alb_zone_id" {
  value       = aws_lb.this.zone_id
  description = "ALB zone ID for Route53"
}

output "target_group_arns" {
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
  description = "Map of target group ARNs"
}

output "target_group_names" {
  value       = { for k, v in aws_lb_target_group.this : k => v.name }
  description = "Map of target group names"
}

output "http_listener_arns" {
  value       = { for k, v in aws_lb_listener.http : k => v.arn }
  description = "Map of HTTP listener ARNs"
}

output "https_listener_arns" {
  value       = { for k, v in aws_lb_listener.https : k => v.arn }
  description = "Map of HTTPS listener ARNs"
}

# ==============================================================================
# CLOUDWATCH
# ==============================================================================

output "cloudwatch_5xx_alarm_arn" {
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.elb_5xx.arn : null
  description = "ARN of the ALB 5XX alarm"
}

output "cloudwatch_target_5xx_alarm_arn" {
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.target_5xx.arn : null
  description = "ARN of the target 5XX alarm"
}

output "cloudwatch_latency_alarm_arn" {
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.latency_high.arn : null
  description = "ARN of the latency alarm"
}

output "cloudwatch_unhealthy_hosts_alarm_arn" {
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.unhealthy_hosts.arn : null
  description = "ARN of the unhealthy hosts alarm"
}
