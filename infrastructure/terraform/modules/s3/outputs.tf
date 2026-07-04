output "bucket_id" {
  value       = aws_s3_bucket.this.id
  description = "Bucket ID"
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "Bucket ARN"
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.this.bucket_domain_name
  description = "Bucket domain name"
}

output "bucket_regional_domain_name" {
  value       = aws_s3_bucket.this.bucket_regional_domain_name
  description = "Bucket regional domain name"
}

output "bucket_website_endpoint" {
  value       = var.website_configuration != null ? aws_s3_bucket_website_configuration.this.website_endpoint : null
  description = "Website endpoint"
}

output "bucket_website_domain" {
  value       = var.website_configuration != null ? aws_s3_bucket_website_configuration.this.website_domain : null
  description = "Website domain"
}

output "iam_user_name" {
  value       = var.create_iam_user ? aws_iam_user.this.name : null
  description = "IAM user name"
}

output "iam_user_arn" {
  value       = var.create_iam_user ? aws_iam_user.this.arn : null
  description = "IAM user ARN"
}

output "iam_access_key_id" {
  value       = var.create_iam_user ? aws_iam_access_key.this.id : null
  description = "IAM access key ID"
  sensitive   = true
}

output "iam_secret_access_key" {
  value       = var.create_iam_user ? aws_iam_access_key.this.secret : null
  description = "IAM secret access key"
  sensitive   = true
}

output "cloudfront_oai_id" {
  value       = var.create_cloudfront_oai ? aws_cloudfront_origin_access_identity.this.id : null
  description = "CloudFront OAI ID"
}

output "cloudfront_oai_iam_arn" {
  value       = var.create_cloudfront_oai ? aws_cloudfront_origin_access_identity.this.iam_arn : null
  description = "CloudFront OAI IAM ARN"
}

output "cloudfront_oai_path" {
  value       = var.create_cloudfront_oai ? aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path : null
  description = "CloudFront OAI path"
}
