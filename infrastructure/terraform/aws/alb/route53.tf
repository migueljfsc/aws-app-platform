resource "aws_route53_record" "hosts" {
  for_each = {
    for h in var.hosts :
    "${h.host}.${h.zone_name}" => h
  }

  zone_id = data.aws_route53_zone.this[each.value.zone_name].zone_id
  name    = each.value.host != "" ? each.value.host : "${var.service_name}-alb"
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}
