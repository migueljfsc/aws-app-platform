locals {
  is_cluster = contains(["aurora", "aurora-mysql", "aurora-postgresql"], var.engine)

  db_identifier = local.is_cluster ? "${var.service_name}-${var.deploy_context}-rds-${replace(var.engine, "aurora-", "")}" : "${var.service_name}-${var.deploy_context}-rds-${var.engine}"

  port = var.port != 0 ? var.port : (
    startswith(var.engine, "aurora-postgresql") || startswith(var.engine, "postgres") ? 5432 :
    startswith(var.engine, "aurora-mysql") || startswith(var.engine, "mysql") || startswith(var.engine, "aurora") ? 3306 :
    startswith(var.engine, "oracle") ? 1521 :
    startswith(var.engine, "sqlserver") ? 1433 :
    5432
  )

  parameter_group_family = var.parameter_group_family != "" ? var.parameter_group_family : (
    var.engine == "aurora-postgresql" ? "aurora-postgresql${split(".", var.engine_version)[0]}" :
    var.engine == "aurora-mysql" ? "aurora-mysql${split(".", var.engine_version)[0]}" :
    var.engine == "postgres" ? "postgres${split(".", var.engine_version)[0]}" :
    var.engine == "mysql" ? "mysql${split(".", var.engine_version)[0]}" :
    var.engine == "mariadb" ? "mariadb${split(".", var.engine_version)[0]}" :
    ""
  )

  create_monitoring_role = var.monitoring_interval > 0 && var.monitoring_role_arn == ""
  monitoring_role_arn    = local.create_monitoring_role ? aws_iam_role.rds_monitoring.arn : var.monitoring_role_arn

  final_snapshot_identifier = "${var.service_name}-${var.deploy_context}-${var.final_snapshot_identifier_prefix}-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Unified endpoint output regardless of resource type
  db_endpoint = local.is_cluster ? aws_rds_cluster.this.endpoint : aws_db_instance.this.address

  db_port = local.is_cluster ? aws_rds_cluster.this.port : aws_db_instance.this.port
}
