data "aws_route53_zone" "public" {
  for_each = local.required_zone_names

  name         = each.value
  private_zone = false
}

data "aws_route53_zone" "private" {
  for_each = toset([
    for z in local.required_zone_names : z
    if anytrue([
      for cert_key, cert in local.certificates_with_route53 : cert.route53_zone_private
    ])
  ])

  name         = each.value
  private_zone = true
}
