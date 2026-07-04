# ==============================================================================
# Redis Replication Group
# ==============================================================================

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = local.cluster_id
  description          = local.replication_group_description

  # Engine
  engine               = var.engine
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = local.port
  parameter_group_name = local.parameter_group_name

  # Topology
  num_node_groups         = var.num_node_groups
  replicas_per_node_group = var.num_cache_nodes

  # High availability
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled

  # Network
  subnet_group_name  = local.subnet_group_name
  security_group_ids = local.security_group_ids

  # Encryption
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  transit_encryption_mode    = var.transit_encryption_enabled ? var.transit_encryption_mode : null
  kms_key_id                 = var.kms_key_id != "" ? var.kms_key_id : null
  auth_token                 = var.auth_token != "" ? var.auth_token : null

  # Maintenance & snapshots
  maintenance_window         = var.maintenance_window
  snapshot_window            = var.snapshot_window
  snapshot_retention_limit   = var.snapshot_retention_limit
  final_snapshot_identifier  = var.final_snapshot_identifier != "" ? var.final_snapshot_identifier : null
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  # Notifications
  notification_topic_arn = var.notification_topic_arn != "" ? var.notification_topic_arn : null

  # Log delivery
  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configurations
    content {
      log_type         = log_delivery_configuration.value.log_type
      destination_type = log_delivery_configuration.value.destination_type
      destination      = log_delivery_configuration.value.destination
      log_format       = log_delivery_configuration.value.log_format
    }
  }

  tags = {
    Name = local.cluster_id
  }

  lifecycle {
    enabled = local.is_redis
  }
}

# ==============================================================================
# Memcached Cluster
# ==============================================================================

resource "aws_elasticache_cluster" "this" {
  cluster_id = local.cluster_id

  # Engine
  engine               = "memcached"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = local.port
  parameter_group_name = local.parameter_group_name

  # Topology
  num_cache_nodes = var.num_cache_nodes

  # Network
  subnet_group_name  = local.subnet_group_name
  security_group_ids = local.security_group_ids

  # Maintenance
  maintenance_window = var.maintenance_window
  apply_immediately  = var.apply_immediately

  # Notifications
  notification_topic_arn = var.notification_topic_arn != "" ? var.notification_topic_arn : null

  tags = {
    Name = local.cluster_id
  }

  lifecycle {
    enabled = !local.is_redis
  }
}

# ==============================================================================
# Subnet Group
# ==============================================================================

resource "aws_elasticache_subnet_group" "this" {
  name       = "${local.cluster_id}-subnet-group"
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.this.ids

  tags = {
    Name = "${local.cluster_id}-subnet-group"
  }

  lifecycle {
    enabled = local.create_subnet_group
  }
}

# ==============================================================================
# Parameter Group
# ==============================================================================

resource "aws_elasticache_parameter_group" "this" {
  name   = "${local.cluster_id}-params"
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = {
    Name = "${local.cluster_id}-params"
  }

  lifecycle {
    enabled               = local.create_parameter_group
    create_before_destroy = true
  }
}
