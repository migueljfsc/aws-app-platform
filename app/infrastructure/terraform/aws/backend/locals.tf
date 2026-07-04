locals {
  ecr_image = var.create_ecr_repo ? module.ecr.repository_url : data.aws_ecr_repository.this.repository_url
}
