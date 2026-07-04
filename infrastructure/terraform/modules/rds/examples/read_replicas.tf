###############################################################################
# PostgreSQL with Multi-node Read Scaling
#
# - Primary instance with 2 reader instances for read scaling
# - Storage autoscaling handled by Aurora automatically
###############################################################################

module "postgres_with_replicas" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  engine         = "aurora-postgresql"
  engine_version = "16.4"
  instance_class = "db.r6g.xlarge"
  instance_count = 3 # 1 Writer + 2 Readers

  database_name   = "analytics"
  master_username = "dbadmin"

  # Backup
  backup_retention_period = 14
  skip_final_snapshot     = false

  # Monitoring
  monitoring_interval                   = 15
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Protection
  deletion_protection = true
}
