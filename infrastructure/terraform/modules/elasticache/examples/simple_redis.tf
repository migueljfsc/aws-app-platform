###############################################################################
# Simple Redis Instance
#
# Minimal configuration — single-node Redis with defaults.
# - Auto-discovers VPC, private subnets, and security group
# - At-rest encryption enabled by default
# - No replicas, no clustering
# - Auto-discovers VPC, private subnets, and security group
###############################################################################

module "redis" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "app-cache"

  engine         = "redis"
  engine_version = "7.1"
  node_type      = "cache.t4g.micro"
}
