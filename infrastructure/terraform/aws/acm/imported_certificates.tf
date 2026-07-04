# Imported Certificates (self-signed or third-party)
resource "aws_acm_certificate" "imported" {
  for_each = var.imported_certificates

  certificate_body  = each.value.certificate_body
  private_key       = each.value.private_key
  certificate_chain = each.value.certificate_chain != "" ? each.value.certificate_chain : null

  tags = {
    Name     = "${var.service_name}-${module.aws_registry.deploy_context}-${each.key}-imported"
    Imported = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}
