resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${var.service_name}.${var.route53_zone_name}"
  type    = "A"
  ttl     = 60
  records = [var.internal ? aws_instance.this.private_ip : aws_instance.this.public_ip]

  lifecycle {
    enabled = var.route53_zone_name != ""
  }
}
