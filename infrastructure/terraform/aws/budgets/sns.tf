module "sns" {
  source = "../../modules/sns/"

  deploy_context = module.aws_registry.deploy_context
  service_name   = var.service_name

  allow_publish_from_services = ["budgets.amazonaws.com"]

  email_subscriptions = var.sns_email_subscriptions
}
