###############################################################################
# MySQL Instance with CloudWatch Logging & Custom Parameters
#
# - Exports error and slow query logs to CloudWatch
# - Custom parameter group for slow query tuning
# - Aurora cluster
###############################################################################

module "mysql" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.04.1"
  instance_class = "db.t4g.medium"
  instance_count = 1

  database_name   = "api"
  master_username = "dbadmin"

  # Custom parameters for slow query logging
  parameter_group_family = "aurora-mysql8.0"
  parameters = [
    {
      name  = "slow_query_log"
      value = "1"
    },
    {
      name  = "long_query_time"
      value = "2"
    },
    {
      name  = "log_output"
      value = "FILE"
    }
  ]

  skip_final_snapshot = true
}
