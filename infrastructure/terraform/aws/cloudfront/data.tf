data "aws_route53_zone" "this" {
  for_each = {
    for h in var.hosts :
    h.zone_name => h
  }

  name         = each.value.zone_name
  private_zone = false
}


data "aws_acm_certificate" "this" {
  provider = aws.use1

  domain      = var.certificate_domain
  most_recent = true
  statuses    = ["ISSUED"]

  lifecycle {
    enabled = var.certificate_domain != ""
  }
}

data "aws_lb" "vpc_origins" {
  for_each = { for k, v in var.vpc_origins : k => v if v.arn == "" }

  name = each.value.name
}

data "aws_wafv2_web_acl" "this" {
  provider = aws.use1

  name  = var.web_acl_name != "" ? var.web_acl_name : "cloudfront-${var.environment}-use1"
  scope = "CLOUDFRONT"
}
