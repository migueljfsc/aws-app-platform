# Certificates
output "certificate_arns" {
  value       = { for k, v in aws_acm_certificate.this : k => v.arn }
  description = "Map of certificate ARNs"
}

output "certificate_ids" {
  value       = { for k, v in aws_acm_certificate.this : k => v.id }
  description = "Map of certificate IDs"
}

output "certificate_domain_names" {
  value       = { for k, v in aws_acm_certificate.this : k => v.domain_name }
  description = "Map of certificate domain names"
}

output "certificate_statuses" {
  value       = { for k, v in aws_acm_certificate.this : k => v.status }
  description = "Map of certificate statuses"
}

output "certificate_domain_validation_options" {
  value       = { for k, v in aws_acm_certificate.this : k => v.domain_validation_options }
  description = "Map of certificate domain validation options"
}

# Imported Certificates
output "imported_certificate_arns" {
  value       = { for k, v in aws_acm_certificate.imported : k => v.arn }
  description = "Map of imported certificate ARNs"
}

output "imported_certificate_ids" {
  value       = { for k, v in aws_acm_certificate.imported : k => v.id }
  description = "Map of imported certificate IDs"
}

# Validation Records
output "validation_record_fqdns" {
  value       = { for k, v in aws_route53_record.validation : k => v.fqdn }
  description = "Map of validation record FQDNs"
}

# Combined (both regular and imported)
output "all_certificate_arns" {
  value = merge(
    { for k, v in aws_acm_certificate.this : k => v.arn },
    { for k, v in aws_acm_certificate.imported : "${k}-imported" => v.arn }
  )
  description = "Map of all certificate ARNs (both regular and imported)"
}
