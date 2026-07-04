###############################################################################
# Simple PostgreSQL Instance
#
# Minimal configuration using only required variables.
# - Secrets Manager handles the master password automatically
# - Subnet group and security groups are auto-discovered from the VPC
# - Default storage configuration (Aurora), Performance Insights enabled
###############################################################################

module "postgres" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  engine         = "aurora-postgresql"
  engine_version = "16.4"
  instance_class = "db.t4g.medium"
  instance_count = 1

  database_name   = "webapp"
  master_username = "dbadmin"

  skip_final_snapshot = true
}
