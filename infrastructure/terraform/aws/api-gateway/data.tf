
data "aws_region" "current" {}

data "aws_wafv2_web_acl" "this" {
  name  = var.web_acl_name != "" ? var.web_acl_name : "api-gateway-${module.aws_registry.deploy_context}"
  scope = "REGIONAL"

  lifecycle {
    enabled = var.attach_web_acl && var.api_type == "REST"
  }
}

data "aws_route53_zone" "private" {
  name         = var.route53_zone_name
  private_zone = true

  lifecycle {
    enabled = var.create_route53_record && var.route53_zone_name != ""
  }
}

data "aws_route53_zone" "public" {
  name         = var.route53_zone_name
  private_zone = false

  lifecycle {
    enabled = var.create_route53_record && var.route53_zone_name != ""
  }
}

data "aws_acm_certificate" "this" {
  domain      = var.certificate_domain_name
  most_recent = true
  statuses    = ["ISSUED"]

  lifecycle {
    enabled = var.certificate_arn == "" && var.certificate_domain_name != ""
  }
}
