resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.route53_record_name != "" ? var.route53_record_name : "${var.service_name}-rds"
  type    = "CNAME"
  ttl     = 300
  records = [local.db_endpoint]


  lifecycle {
    enabled = var.create_route53_record
  }
}
