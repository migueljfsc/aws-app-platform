module "sns_alerts" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "alerts"

  display_name = "Dev Alerts" # Overrides topic name {service_name-deploy_context}

  # Email subscriptions
  email_subscriptions = {
    devops_team = {
      endpoint = "devops@example.com"
    }
    oncall = {
      endpoint = "oncall@example.com"
    }
  }
}
