output "zone_id" {
  value       = local.zone_id
  description = "Route53 zone ID"
}

output "zone_arn" {
  value       = var.create_zone ? aws_route53_zone.this.arn : null
  description = "Route53 zone ARN"
}

output "zone_name" {
  value       = var.zone_name
  description = "Route53 zone name"
}

output "name_servers" {
  value       = var.create_zone ? aws_route53_zone.this.name_servers : []
  description = "Route53 zone name servers"
}

output "primary_name_server" {
  value       = var.create_zone ? aws_route53_zone.this.primary_name_server : null
  description = "Primary name server"
}

output "record_names" {
  value       = { for k, v in aws_route53_record.this : k => v.name }
  description = "Map of record names"
}

output "record_fqdns" {
  value       = { for k, v in aws_route53_record.this : k => v.fqdn }
  description = "Map of record FQDNs"
}

output "health_check_ids" {
  value       = { for k, v in aws_route53_health_check.this : k => v.id }
  description = "Map of health check IDs"
}

output "health_check_arns" {
  value       = { for k, v in aws_route53_health_check.this : k => v.arn }
  description = "Map of health check ARNs"
}
