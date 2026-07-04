# Quota Requests (explicit codes)
output "quota_request_ids" {
  value       = { for k, v in aws_servicequotas_service_quota.this : k => v.id }
  description = "Map of quota request IDs (explicit codes)"
}

output "quota_request_arns" {
  value       = { for k, v in aws_servicequotas_service_quota.this : k => v.arn }
  description = "Map of quota request ARNs (explicit codes)"
}

# Current Quota Information (explicit codes)
output "current_quota_values" {
  value = {
    for k, v in data.aws_servicequotas_service_quota.current :
    k => {
      current_value = v.value
      default_value = v.default_value
      adjustable    = v.adjustable
      quota_name    = v.quota_name
      quota_code    = v.quota_code
      service_name  = v.service_name
      usage_metric  = v.usage_metric
    }
  }
  description = "Current quota information (explicit codes)"
}

# Combined Summary
output "quota_summary" {
  value = merge(
    {
      for k, v in var.quota_increases :
      "${k}_by_name" => {
        service_code  = v.service_code
        quota_code    = try(data.aws_servicequotas_service_quota.current[k].quota_code, null)
        quota_name    = v.quota_name
        current_value = try(data.aws_servicequotas_service_quota.current[k].value, null)
        desired_value = v.desired_value
        increase      = v.desired_value - try(data.aws_servicequotas_service_quota.current[k].value, 0)
        adjustable    = try(data.aws_servicequotas_service_quota.current[k].adjustable, null)
      }
    }
  )
  description = "Summary of all quota increase requests"
}
