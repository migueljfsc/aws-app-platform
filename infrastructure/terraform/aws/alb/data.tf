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

data "aws_security_groups" "this" {
  filter {
    name = "tag:Name"
    values = [
      "app-${module.aws_registry.deploy_context}-alb",
      "app-${module.aws_registry.deploy_context}-cloudfront-alb"
    ]
  }
}

data "aws_route53_zone" "this" {
  for_each = {
    for h in var.hosts :
    h.zone_name => h
  }

  name         = each.value.zone_name
  private_zone = var.internal
}

data "aws_acm_certificate" "this" {
  for_each = toset(flatten([
    for listener in var.https_listeners :
    listener.certificate_domains
  ]))

  domain      = each.value
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_sns_topic" "critical" {
  name = "critical-alerts"

  lifecycle {
    enabled = var.enable_cloudwatch_alarms
  }
}

data "aws_sns_topic" "warning" {
  name = "warning-alerts"

  lifecycle {
    enabled = var.enable_cloudwatch_alarms
  }
}
