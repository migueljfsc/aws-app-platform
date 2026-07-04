# Web ACL
output "web_acl_arn" {
  value       = aws_wafv2_web_acl.this.arn
  description = "Web ACL ARN"
}

output "web_acl_id" {
  value       = aws_wafv2_web_acl.this.id
  description = "Web ACL ID"
}

output "web_acl_capacity" {
  value       = aws_wafv2_web_acl.this.capacity
  description = "Web ACL capacity"
}

# IP Sets
output "ip_set_arns" {
  value       = { for k, v in aws_wafv2_ip_set.this : k => v.arn }
  description = "Map of IP set ARNs"
}

output "ip_set_ids" {
  value       = { for k, v in aws_wafv2_ip_set.this : k => v.id }
  description = "Map of IP set IDs"
}

# Regex Pattern Sets
output "regex_pattern_set_arns" {
  value       = { for k, v in aws_wafv2_regex_pattern_set.this : k => v.arn }
  description = "Map of regex pattern set ARNs"
}

output "regex_pattern_set_ids" {
  value       = { for k, v in aws_wafv2_regex_pattern_set.this : k => v.id }
  description = "Map of regex pattern set IDs"
}
