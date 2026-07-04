# ==============================================================================
# Redis Outputs
# ==============================================================================

output "replication_group_id" {
  value       = aws_elasticache_replication_group.this.id
  description = "Redis replication group ID"
}

output "replication_group_arn" {
  value       = aws_elasticache_replication_group.this.arn
  description = "Redis replication group ARN"
}

output "primary_endpoint_address" {
  value       = local.is_redis ? aws_elasticache_replication_group.this.primary_endpoint_address : null
  description = "Redis primary endpoint address"
}

output "reader_endpoint_address" {
  value       = local.is_redis ? aws_elasticache_replication_group.this.reader_endpoint_address : null
  description = "Redis reader endpoint address"
}

output "configuration_endpoint_address" {
  value       = local.is_redis && var.num_node_groups > 1 ? aws_elasticache_replication_group.this.configuration_endpoint_address : null
  description = "Redis cluster mode configuration endpoint address"
}

# ==============================================================================
# Memcached Outputs
# ==============================================================================

output "cluster_id" {
  value       = local.is_redis ? null : aws_elasticache_cluster.this.cluster_id
  description = "Memcached cluster ID"
}

output "cluster_cache_nodes" {
  value       = local.is_redis ? [] : aws_elasticache_cluster.this.cache_nodes
  description = "Memcached cache node endpoints"
}

output "cluster_configuration_endpoint" {
  value       = local.is_redis ? null : aws_elasticache_cluster.this.configuration_endpoint
  description = "Memcached configuration endpoint"
}

# ==============================================================================
# Common Outputs
# ==============================================================================

output "engine" {
  value       = var.engine
  description = "Cache engine"
}

output "port" {
  value       = local.port
  description = "Cache port"
}

output "subnet_group_name" {
  value       = local.subnet_group_name
  description = "ElastiCache subnet group name"
}

output "parameter_group_name" {
  value       = local.parameter_group_name
  description = "ElastiCache parameter group name"
}

output "dns_record" {
  description = "Route53 CNAME record FQDN (empty if DNS not enabled)"
  value       = var.route53_zone_name != "" ? aws_route53_record.this.fqdn : ""
}
