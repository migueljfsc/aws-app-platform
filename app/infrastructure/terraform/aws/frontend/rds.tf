module "rds" {
  source = "../../../../../infrastructure/terraform/modules/rds"

  shared_deploy_context = module.aws_registry.shared_deploy_context
  deploy_context        = module.aws_registry.deploy_context
  service_name          = var.service_name

  engine         = "postgres"
  engine_version = "17.7"
  instance_class = "db.t3.medium"
  instance_count = 1

  master_username = "admin"

  database_name = "db"

  skip_final_snapshot = true

  route53_domain_name = "${var.environment}.my.domain.com"
}
