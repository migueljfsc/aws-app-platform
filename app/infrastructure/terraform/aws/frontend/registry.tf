module "aws_registry" {
  source = "../../../../../infrastructure/terraform/modules/registry"

  repository = "https://github.com/migueljfsc/aws-app-platform"

  environment  = var.environment
  service_name = var.service_name
}
