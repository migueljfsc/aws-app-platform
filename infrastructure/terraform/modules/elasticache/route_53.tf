resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${var.service_name}-redis.${var.route53_zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [local.elasticache_endpoint]

  lifecycle {
    enabled = var.route53_zone_name != ""
  }
}
