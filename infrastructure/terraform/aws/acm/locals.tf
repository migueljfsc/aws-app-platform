locals {
  certificates_with_route53 = {
    for cert_key, cert in var.certificates :
    cert_key => cert if cert.create_route53_records && cert.validation_method == "DNS"
  }

  # Unique zone names needed across all certs, derived from each domain
  required_zone_names = toset(flatten([
    for cert_key, cert in local.certificates_with_route53 : [
      for dvo in aws_acm_certificate.this[cert_key].domain_validation_options :
      replace(dvo.domain_name, "/^\\*\\./", "")
      if cert.route53_zone_id == ""
    ]
  ]))

  domain_validation_options = flatten([
    for cert_key, cert in aws_acm_certificate.this : [
      for dvo in cert.domain_validation_options : {
        cert_key              = cert_key
        domain_name           = dvo.domain_name
        resource_record_name  = dvo.resource_record_name
        resource_record_type  = dvo.resource_record_type
        resource_record_value = dvo.resource_record_value
        route53_zone_private  = local.certificates_with_route53[cert_key].route53_zone_private
        route53_zone_id       = local.certificates_with_route53[cert_key].route53_zone_id
        # Derived zone name for lookup when no explicit zone_id provided
        zone_name = replace(dvo.domain_name, "/^\\*\\./", "")
      }
    ] if contains(keys(local.certificates_with_route53), cert_key)
  ])
}
