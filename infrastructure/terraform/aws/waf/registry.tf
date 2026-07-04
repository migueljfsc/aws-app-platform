module "aws_registry" {
  source = "../../modules/registry/"

  repository = "https://github.com/migueljfsc/app-infra"

  environment  = var.environment
  service_name = var.service_name
  region       = var.scope == "CLOUDFRONT" ? "us-east-1" : "eu-west-3"
}
