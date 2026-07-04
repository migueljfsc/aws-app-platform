output "distribution_id" {
  value       = aws_cloudfront_distribution.this.id
  description = "CloudFront distribution ID"
}

output "distribution_arn" {
  value       = aws_cloudfront_distribution.this.arn
  description = "CloudFront distribution ARN"
}

output "distribution_domain_name" {
  value       = aws_cloudfront_distribution.this.domain_name
  description = "CloudFront distribution domain name"
}

output "distribution_hosted_zone_id" {
  value       = aws_cloudfront_distribution.this.hosted_zone_id
  description = "CloudFront Route53 zone ID"
}

output "distribution_status" {
  value       = aws_cloudfront_distribution.this.status
  description = "Distribution status"
}

output "distribution_etag" {
  value       = aws_cloudfront_distribution.this.etag
  description = "Distribution ETag"
}

output "certificate_arn" {
  value       = var.certificate_domain != "" ? data.aws_acm_certificate.this.arn : ""
  description = "ACM certificate ARN used by the distribution"
}

output "route53_record_names" {
  value       = { for k, v in aws_route53_record.this : k => v.name }
  description = "Map of Route53 record names"
}

output "route53_record_fqdns" {
  value       = { for k, v in aws_route53_record.this : k => v.fqdn }
  description = "Map of Route53 record FQDNs"
}

output "vpc_origin_ids" {
  value       = { for k, v in aws_cloudfront_vpc_origin.this : k => v.id }
  description = "Map of VPC origin IDs"
}

output "vpc_origin_arns" {
  value       = { for k, v in aws_cloudfront_vpc_origin.this : k => v.arn }
  description = "Map of VPC origin ARNs"
}
