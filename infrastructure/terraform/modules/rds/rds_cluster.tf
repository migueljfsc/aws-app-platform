resource "aws_rds_cluster" "this" {
  cluster_identifier = local.db_identifier

  engine         = var.engine
  engine_version = var.engine_version

  database_name                 = var.database_name != "" ? var.database_name : var.service_name
  master_username               = var.master_username
  master_password               = var.manage_master_user_password ? null : var.master_password
  manage_master_user_password   = var.manage_master_user_password
  master_user_secret_kms_key_id = var.master_user_secret_kms_key_id != "" ? var.master_user_secret_kms_key_id : null

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id != "" ? var.kms_key_id : null

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = length(var.vpc_security_group_ids) > 0 ? var.vpc_security_group_ids : data.aws_security_groups.this.ids
  port                   = local.port

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.backup_window
  preferred_maintenance_window = var.maintenance_window
  skip_final_snapshot          = var.skip_final_snapshot
  final_snapshot_identifier    = var.skip_final_snapshot ? null : local.final_snapshot_identifier
  copy_tags_to_snapshot        = var.copy_tags_to_snapshot

  db_cluster_parameter_group_name = var.cluster_parameter_group_name != "" ? aws_rds_cluster_parameter_group.this.name : null

  apply_immediately                   = var.apply_immediately
  deletion_protection                 = var.deletion_protection
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  allow_major_version_upgrade         = var.allow_major_version_upgrade

  snapshot_identifier = var.snapshot_identifier != "" ? var.snapshot_identifier : null

  dynamic "restore_to_point_in_time" {
    for_each = var.restore_to_point_in_time != null ? [var.restore_to_point_in_time] : []
    content {
      source_cluster_identifier  = restore_to_point_in_time.value.source_cluster_identifier
      restore_to_time            = restore_to_point_in_time.value.restore_to_time
      use_latest_restorable_time = restore_to_point_in_time.value.use_latest_restorable_time
    }
  }

  tags = {
    Name = "${var.service_name}-${var.deploy_context}-rds"
  }

  lifecycle {
    enabled        = local.is_cluster
    ignore_changes = [snapshot_identifier, master_password]
  }

  depends_on = [
    aws_rds_cluster_parameter_group.this,
    aws_db_parameter_group.this
  ]
}

resource "aws_rds_cluster_instance" "this" {
  count = local.is_cluster ? var.instance_count : 0

  identifier         = "${local.db_identifier}-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version

  db_subnet_group_name = aws_db_subnet_group.this.name
  publicly_accessible  = var.publicly_accessible

  db_parameter_group_name = var.parameter_group_name != "" ? aws_db_parameter_group.this.name : null

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id != "" ? var.performance_insights_kms_key_id : null

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? local.monitoring_role_arn : null

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately
  ca_cert_identifier         = var.ca_cert_identifier != "" ? var.ca_cert_identifier : null

  tags = {
    Name = "${var.service_name}-${var.deploy_context}-rds-instance-${count.index + 1}"
  }

  depends_on = [aws_iam_role_policy_attachment.rds_monitoring]
}

resource "aws_rds_cluster_parameter_group" "this" {
  name   = var.cluster_parameter_group_name
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = { Name = var.cluster_parameter_group_name }

  lifecycle {
    enabled               = local.is_cluster && var.cluster_parameter_group_name != ""
    create_before_destroy = true
  }
}
