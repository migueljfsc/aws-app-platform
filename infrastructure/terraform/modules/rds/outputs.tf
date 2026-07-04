# ==============================================================================
# CLUSTER OUTPUTS (Aurora only)
# ==============================================================================

output "cluster_id" {
  value       = local.is_cluster ? aws_rds_cluster.this.id : null
  description = "Aurora cluster ID"
}

output "cluster_arn" {
  value       = local.is_cluster ? aws_rds_cluster.this.arn : null
  description = "Aurora cluster ARN"
}

output "cluster_endpoint" {
  value       = local.is_cluster ? aws_rds_cluster.this.endpoint : null
  description = "Aurora writer endpoint"
}

output "cluster_reader_endpoint" {
  value       = local.is_cluster ? aws_rds_cluster.this.reader_endpoint : null
  description = "Aurora read-only endpoint, load-balanced across replicas"
}

output "cluster_hosted_zone_id" {
  value       = local.is_cluster ? aws_rds_cluster.this.hosted_zone_id : null
  description = "Route53 hosted zone ID for the Aurora cluster"
}

output "cluster_instances" {
  value = local.is_cluster ? {
    for k, v in aws_rds_cluster_instance.this : k => {
      id                = v.id
      arn               = v.arn
      endpoint          = v.endpoint
      availability_zone = v.availability_zone
    }
  } : null
  description = "Map of Aurora cluster instances"
}

# ==============================================================================
# INSTANCE OUTPUTS (non-Aurora only)
# ==============================================================================

output "instance_id" {
  value       = local.is_cluster ? null : aws_db_instance.this.id
  description = "RDS instance ID"
}

output "instance_arn" {
  value       = local.is_cluster ? null : aws_db_instance.this.arn
  description = "RDS instance ARN"
}

output "instance_endpoint" {
  value       = local.is_cluster ? null : aws_db_instance.this.address
  description = "RDS instance endpoint"
}

output "instance_hosted_zone_id" {
  value       = local.is_cluster ? null : aws_db_instance.this.hosted_zone_id
  description = "Route53 hosted zone ID for the RDS instance"
}

# ==============================================================================
# UNIFIED OUTPUTS (works for both Aurora and non-Aurora)
# ==============================================================================

output "endpoint" {
  value       = local.db_endpoint
  description = "Database endpoint (writer for Aurora, instance address for non-Aurora)"
}

output "port" {
  value       = local.db_port
  description = "Database port"
}

output "database_name" {
  value       = local.is_cluster ? aws_rds_cluster.this.database_name : aws_db_instance.this.db_name
  description = "Database name"
}

output "master_username" {
  value       = local.is_cluster ? aws_rds_cluster.this.master_username : aws_db_instance.this.username
  description = "Master username"
  sensitive   = true
}

output "engine" {
  value       = local.is_cluster ? aws_rds_cluster.this.engine : aws_db_instance.this.engine
  description = "Database engine"
}

output "engine_version" {
  value       = local.is_cluster ? aws_rds_cluster.this.engine_version_actual : aws_db_instance.this.engine_version_actual
  description = "Actual database engine version"
}

output "master_user_secret_arn" {
  value = (
    local.is_cluster
    ? (var.manage_master_user_password && length(aws_rds_cluster.this.master_user_secret) > 0 ? aws_rds_cluster.this.master_user_secret[0].secret_arn : null)
    : (var.manage_master_user_password && length(aws_db_instance.this.master_user_secret) > 0 ? aws_db_instance.this.master_user_secret[0].secret_arn : null)
  )
  description = "ARN of the master user secret in Secrets Manager"
}

output "master_user_secret_kms_key_id" {
  value = (
    local.is_cluster
    ? (var.manage_master_user_password && length(aws_rds_cluster.this.master_user_secret) > 0 ? aws_rds_cluster.this.master_user_secret[0].kms_key_id : null)
    : (var.manage_master_user_password && length(aws_db_instance.this.master_user_secret) > 0 ? aws_db_instance.this.master_user_secret[0].kms_key_id : null)
  )
  description = "KMS key ID used to encrypt the master user secret"
}

output "connection_string" {
  value       = "postgresql://${local.db_endpoint}/${local.is_cluster ? aws_rds_cluster.this.database_name : aws_db_instance.this.db_name}"
  description = "Example connection string (excludes credentials)"
  sensitive   = true
}

# ==============================================================================
# SHARED RESOURCE OUTPUTS
# ==============================================================================

output "db_subnet_group_name" {
  value       = aws_db_subnet_group.this.name
  description = "DB subnet group name"
}

output "db_subnet_group_arn" {
  value       = aws_db_subnet_group.this.arn
  description = "DB subnet group ARN"
}

output "cluster_parameter_group_name" {
  value       = local.is_cluster && var.cluster_parameter_group_name != "" ? aws_rds_cluster_parameter_group.this.name : null
  description = "Aurora cluster parameter group name"
}

output "parameter_group_name" {
  value       = var.parameter_group_name != "" ? aws_db_parameter_group.this.name : null
  description = "DB instance parameter group name"
}

output "parameter_group_arn" {
  value       = var.parameter_group_name != "" ? aws_db_parameter_group.this.arn : null
  description = "DB instance parameter group ARN"
}

output "monitoring_role_arn" {
  value       = local.monitoring_role_arn
  description = "Enhanced monitoring IAM role ARN"
}

output "route53_record_fqdn" {
  value       = var.create_route53_record ? aws_route53_record.this.fqdn : null
  description = "FQDN of the Route 53 record"
}
