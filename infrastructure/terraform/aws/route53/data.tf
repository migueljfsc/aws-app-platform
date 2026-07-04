data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = var.vpc_name != "" ? [var.vpc_name] : ["app-${module.aws_registry.deploy_context}-vpc"]
  }

  lifecycle {
    enabled = var.private_zone
  }
}

data "aws_route53_zone" "this" {
  name         = var.zone_name
  private_zone = var.private_zone

  lifecycle {
    enabled = var.create_zone == false
  }
}
