output "bucket_id" {
  value       = module.s3.bucket_id
  description = "Bucket ID"
}

output "bucket_arn" {
  value       = module.s3.bucket_arn
  description = "Bucket ARN"
}

output "bucket_domain_name" {
  value       = module.s3.bucket_domain_name
  description = "Bucket domain name"
}

output "bucket_regional_domain_name" {
  value       = module.s3.bucket_regional_domain_name
  description = "Bucket regional domain name"
}
