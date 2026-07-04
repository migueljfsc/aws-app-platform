# Look up quota codes by name
data "aws_servicequotas_service_quota" "current" {
  for_each = var.quota_increases

  service_code = each.value.service_code
  quota_name   = each.value.quota_name
}
