data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = var.vpc_name != "" ? [var.vpc_name] : ["app-${module.aws_registry.deploy_context}-vpc"]
  }
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Type"
    values = [var.internal ? "private" : "public"]
  }
}

data "aws_route53_zone" "this" {
  name         = var.route53_zone_name
  private_zone = var.internal

  lifecycle {
    enabled = var.route53_zone_name != ""
  }
}

data "aws_security_group" "external" {
  for_each = toset([for r in var.external_sg_inbound_rules : r.security_group_name])

  filter {
    name   = "tag:Name"
    values = [each.key]
  }

  vpc_id = data.aws_vpc.this.id
}
