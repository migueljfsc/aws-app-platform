###############################################################################
# Production Redis Cluster
#
# - Cluster mode with 3 shards, 1 replica per shard
# - Automatic failover and Multi-AZ
# - In-transit and at-rest encryption
# - 7-day snapshot retention
# - CloudWatch slow-log delivery
# - Custom parameters for memory management
# - Auto-discovers VPC, private subnets, and security group
###############################################################################

module "redis_cluster" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "app-cache"

  engine         = "redis"
  engine_version = "7.1"
  node_type      = "cache.r7g.large"

  # Cluster topology: 3 shards × (1 primary + 1 replica)
  num_node_groups = 3
  num_cache_nodes = 1

  # High availability
  automatic_failover_enabled = true
  multi_az_enabled           = true

  # Encryption
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  transit_encryption_mode    = "required"

  # Snapshots
  snapshot_retention_limit = 7
  snapshot_window          = "02:00-03:00"
  maintenance_window       = "sun:04:00-sun:05:00"

  # Custom parameters
  parameter_group_family = "redis7"
  parameters = [
    {
      name  = "maxmemory-policy"
      value = "allkeys-lru"
    },
    {
      name  = "notify-keyspace-events"
      value = "Ex"
    }
  ]

  # Log delivery
  log_delivery_configurations = [
    {
      log_type         = "slow-log"
      destination_type = "cloudwatch-logs"
      destination      = "/aws/elasticache/platform-cache"
      log_format       = "json"
    }
  ]
}
