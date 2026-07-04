module "github" {
  source = "../../../../infrastructure/terraform/modules/github"

  service_name        = var.service_name
  github_organization = var.github_organization
}
