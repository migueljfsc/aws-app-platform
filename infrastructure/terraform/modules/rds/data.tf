data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = var.vpc_name != "" ? [var.vpc_name] : ["app-${var.deploy_context}-vpc"]
  }
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_security_groups" "this" {
  filter {
    name   = "tag:Name"
    values = ["app-${var.deploy_context}-rds"]
  }
}

data "aws_route53_zone" "this" {
  name         = var.route53_domain_name
  private_zone = var.route53_private_zone

  lifecycle {
    enabled = var.create_route53_record
  }
}
