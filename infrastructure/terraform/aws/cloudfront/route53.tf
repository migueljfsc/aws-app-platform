resource "aws_route53_record" "this" {
  for_each = {
    for h in var.hosts :
    "${h.host}.${h.zone_name}" => h
  }

  zone_id = data.aws_route53_zone.this[each.value.zone_name].zone_id
  name    = each.value.host != "" ? each.value.host : each.value.zone_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = each.value.evaluate_target_health
  }
}
