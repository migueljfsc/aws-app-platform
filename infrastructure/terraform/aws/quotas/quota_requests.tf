# Service Quota Increase Requests (looked up by name)
resource "aws_servicequotas_service_quota" "this" {
  for_each = var.quota_increases

  service_code = each.value.service_code
  quota_code   = data.aws_servicequotas_service_quota.current[each.key].quota_code
  value        = each.value.desired_value
}
