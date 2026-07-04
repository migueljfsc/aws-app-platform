###############################################################################
# Restore PostgreSQL from Snapshot
#
# - Creates a new instance from an existing Aurora snapshot
# - Engine, storage, and database name are inherited from the snapshot
# - Only instance class, cluster size and network configuration need to be specified
###############################################################################

module "postgres_restored" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  engine         = "aurora-postgresql"
  engine_version = "16.4"
  instance_class = "db.t4g.medium"
  instance_count = 1

  master_username = "dbadmin"

  # Restore from snapshot
  snapshot_identifier = "webapp-production-final-2026-02-24"

  # Network
  vpc_security_group_ids = ["sg-0a1b2c3d4e5f60001"]

  # No need for backups or protection on a restored staging copy
  backup_retention_period = 1 # Aurora requires at least 1 day
  skip_final_snapshot     = true
  deletion_protection     = false
}
