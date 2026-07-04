###############################################################################
# Memcached Cluster
#
# - 3-node Memcached cluster for distributed caching
# - Custom parameters for memory and connection tuning
# - Auto-discovers VPC, private subnets, and security group
###############################################################################

module "memcached_cluster" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "app-cache"

  engine         = "memcached"
  engine_version = "1.6.22"
  node_type      = "cache.r7g.large"

  num_cache_nodes = 3

  # Custom parameters
  parameter_group_family = "memcached1.6"
  parameters = [
    {
      name  = "max_simultaneous_connections"
      value = "65000"
    },
    {
      name  = "chunk_size"
      value = "96"
    }
  ]

  # Maintenance
  maintenance_window = "sun:04:00-sun:05:00"
}
