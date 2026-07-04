data "aws_ecr_repository" "this" {
  name = var.service_name


  lifecycle {
    enabled = !var.create_ecr_repo
  }
}
