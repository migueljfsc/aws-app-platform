###############################################################################
# Production-Grade PostgreSQL Instance
#
# - Multi-instance for high availability (writer + reader)
# - Deletion protection enabled
# - 30-day backup retention
# - Enhanced monitoring at 5-second intervals
# - Performance Insights with 31-day retention
# - Blue/green deployments for safer updates
# - Custom parameter group
# - Explicit subnet and security group IDs
###############################################################################

module "postgres_production" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  engine         = "aurora-postgresql"
  engine_version = "16.4"
  instance_class = "db.r6g.large"
  instance_count = 2 # Writer + Reader for HA

  database_name   = "platform"
  master_username = "dbadmin"

  # Storage configuration
  storage_encrypted = true

  # Network — explicit subnet and security group IDs
  subnet_ids             = ["subnet-0a1b2c3d4e5f60001", "subnet-0a1b2c3d4e5f60002", "subnet-0a1b2c3d4e5f60003"]
  vpc_security_group_ids = ["sg-0a1b2c3d4e5f60001"]

  # Backup
  backup_retention_period = 30
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  skip_final_snapshot     = false

  # Monitoring
  monitoring_interval = 5

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 31

  # Custom parameters
  parameter_group_family = "aurora-postgresql16"
  parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    },
    {
      name         = "log_min_duration_statement"
      value        = "1000"
      apply_method = "immediate"
    },
    {
      name  = "idle_in_transaction_session_timeout"
      value = "60000"
    }
  ]

  # Protection
  deletion_protection         = true
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  apply_immediately           = false
}
