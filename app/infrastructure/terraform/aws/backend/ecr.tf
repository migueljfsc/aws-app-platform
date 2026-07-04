module "ecr" {
  source = "../../../../../infrastructure/terraform/modules/ecr"

  service_name = var.service_name

  lifecycle {
    enabled = var.create_ecr_repo
  }
}

module "ecr_fb" {
  source = "../../../../../infrastructure/terraform/modules/ecr"

  service_name = "${var.service_name}-fb"

  lifecycle {
    enabled = var.create_ecr_repo
  }
}
