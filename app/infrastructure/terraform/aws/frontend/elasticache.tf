module "redis" {
  source = "../../../../../infrastructure/terraform/modules/elasticache"

  shared_deploy_context = module.aws_registry.shared_deploy_context
  deploy_context        = module.aws_registry.deploy_context
  service_name          = var.service_name

  engine         = "valkey"
  engine_version = "9.0"
  node_type      = "cache.t4g.small"

  route53_zone_name = "${var.environment}.my.domain.com"
}
