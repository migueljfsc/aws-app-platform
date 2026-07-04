###############################################################################
# Memcached Cluster
#
# - 3-node Memcached cluster for distributed caching
# - Auto-discovers VPC, private subnets, and security group
###############################################################################

module "memcached" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "app-cache"

  engine         = "valkey"
  engine_version = "1.6.22"
  node_type      = "cache.t4g.micro"

  num_cache_nodes = 3
}
