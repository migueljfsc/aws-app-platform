locals {
  is_redis   = contains(["redis", "valkey"], var.engine)
  cluster_id = "${var.service_name}-${var.deploy_context}"

  # Auto-detect port based on engine
  port = var.port != 0 ? var.port : (local.is_redis ? 6379 : 11211)

  # Auto-detect parameter group family
  parameter_group_family = var.parameter_group_family != "" ? var.parameter_group_family : (
    var.engine == "memcached" ? "memcached${split(".", var.engine_version)[0]}.${split(".", var.engine_version)[1]}" :
    var.engine == "valkey" ? "valkey${split(".", var.engine_version)[0]}" :
    "redis${split(".", var.engine_version)[0]}"
  )

  # Subnet group
  create_subnet_group = var.subnet_group_name == ""
  subnet_group_name   = local.create_subnet_group ? aws_elasticache_subnet_group.this.name : var.subnet_group_name
  security_group_ids  = length(var.vpc_security_group_ids) > 0 ? var.vpc_security_group_ids : data.aws_security_groups.this.ids

  # Parameter group
  create_parameter_group = var.parameter_group_name == "" && length(var.parameters) > 0
  parameter_group_name   = local.create_parameter_group ? aws_elasticache_parameter_group.this.name : var.parameter_group_name

  # Replication group description
  replication_group_description = var.description != "" ? var.description : "ElastiCache replication group for ${local.cluster_id}"

  elasticache_endpoint = local.is_redis ? (
    var.num_node_groups > 1
    ? aws_elasticache_replication_group.this.configuration_endpoint_address
    : aws_elasticache_replication_group.this.primary_endpoint_address
  ) : aws_elasticache_cluster.this.cluster_address
}
