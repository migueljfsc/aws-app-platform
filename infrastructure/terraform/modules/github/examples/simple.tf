module "github" {
  source = "../"

  service_name        = "app-infra"
  github_organization = "migueljfsc"

  required_checks = [
    {
      context        = "Pre-commit checks"
      integration_id = 15368 # Github Actions - curl https://api.github.com/apps/github-actions
    }
  ]
}
