output "repository_arn" {
  value       = aws_ecr_repository.this.arn
  description = "ECR repository ARN"
}

output "repository_url" {
  value       = aws_ecr_repository.this.repository_url
  description = "ECR repository URL"
}

output "repository_name" {
  value       = aws_ecr_repository.this.name
  description = "ECR repository name"
}

output "registry_id" {
  value       = aws_ecr_repository.this.registry_id
  description = "Registry ID"
}

output "repository_uri" {
  value       = "${aws_ecr_repository.this.repository_url}:latest"
  description = "Full repository URI with latest tag"
}
