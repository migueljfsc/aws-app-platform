# ACM Certificates
resource "aws_acm_certificate" "this" {
  for_each = var.certificates

  domain_name               = each.value.domain_name
  subject_alternative_names = each.value.subject_alternative_names
  validation_method         = each.value.validation_method
  key_algorithm             = each.value.key_algorithm

  options {
    certificate_transparency_logging_preference = each.value.certificate_transparency_logging
  }

  dynamic "validation_option" {
    for_each = each.value.validation_options
    content {
      domain_name       = validation_option.value.domain_name
      validation_domain = validation_option.value.validation_domain
    }
  }

  tags = {
    Name       = "${var.service_name}-${module.aws_registry.deploy_context}-${each.key}"
    DomainName = each.value.domain_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Certificate Validation
resource "aws_acm_certificate_validation" "this" {
  for_each = {
    for cert_key, cert in var.certificates :
    cert_key => cert if cert.wait_for_validation && cert.validation_method == "DNS" && cert.create_route53_records
  }

  certificate_arn = aws_acm_certificate.this[each.key].arn

  validation_record_fqdns = [
    for dvo in local.domain_validation_options :
    aws_route53_record.validation["${dvo.cert_key}-${dvo.domain_name}"].fqdn
    if dvo.cert_key == each.key
  ]

  depends_on = [aws_route53_record.validation]
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in local.domain_validation_options :
    "${dvo.cert_key}-${dvo.domain_name}" => dvo
  }

  zone_id = (
    each.value.route53_zone_id != "" ? each.value.route53_zone_id :
    each.value.route53_zone_private ?
    data.aws_route53_zone.private[each.value.zone_name].zone_id :
    data.aws_route53_zone.public[each.value.zone_name].zone_id
  )

  name            = each.value.resource_record_name
  type            = each.value.resource_record_type
  ttl             = 60
  records         = [each.value.resource_record_value]
  allow_overwrite = true

  depends_on = [aws_acm_certificate.this]
}
