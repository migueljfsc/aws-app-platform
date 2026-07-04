locals {
  ecr_image = var.create_ecr_repo ? module.ecr.repository_url : data.aws_ecr_repository.this.repository_url

  listener_rule_priorities = {
    dev = 100
    stg = 200
    prd = 300
  }
}
