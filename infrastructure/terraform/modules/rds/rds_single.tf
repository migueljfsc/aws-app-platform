
resource "aws_db_instance" "this" {
  identifier = local.db_identifier

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name                       = var.database_name != "" ? var.database_name : var.service_name
  username                      = var.master_username
  password                      = var.manage_master_user_password ? null : var.master_password
  manage_master_user_password   = var.manage_master_user_password
  master_user_secret_kms_key_id = var.master_user_secret_kms_key_id != "" ? var.master_user_secret_kms_key_id : null

  storage_type       = var.storage_type
  allocated_storage  = var.allocated_storage
  storage_encrypted  = var.storage_encrypted
  kms_key_id         = var.kms_key_id != "" ? var.kms_key_id : null
  iops               = var.iops != 0 ? var.iops : null
  storage_throughput = var.storage_throughput != 0 ? var.storage_throughput : null

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = length(var.vpc_security_group_ids) > 0 ? var.vpc_security_group_ids : data.aws_security_groups.this.ids
  port                   = local.port
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az

  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : local.final_snapshot_identifier
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot

  parameter_group_name = var.parameter_group_name != "" ? aws_db_parameter_group.this.name : null

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id != "" ? var.performance_insights_kms_key_id : null

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? local.monitoring_role_arn : null

  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  apply_immediately                   = var.apply_immediately
  deletion_protection                 = var.deletion_protection
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  ca_cert_identifier                  = var.ca_cert_identifier != "" ? var.ca_cert_identifier : null

  snapshot_identifier = var.snapshot_identifier != "" ? var.snapshot_identifier : null

  dynamic "restore_to_point_in_time" {
    for_each = var.restore_to_point_in_time != null ? [var.restore_to_point_in_time] : []
    content {
      source_db_instance_identifier = restore_to_point_in_time.value.source_cluster_identifier
      restore_time                  = restore_to_point_in_time.value.restore_to_time
      use_latest_restorable_time    = restore_to_point_in_time.value.use_latest_restorable_time
    }
  }

  tags = {
    Name = "${var.service_name}-${var.deploy_context}-rds"
  }

  lifecycle {
    enabled        = !local.is_cluster
    ignore_changes = [snapshot_identifier, password]
  }

  depends_on = [
    aws_db_parameter_group.this,
    aws_iam_role_policy_attachment.rds_monitoring
  ]
}
