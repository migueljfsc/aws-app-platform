# API Keys (REST API only)
resource "aws_api_gateway_api_key" "this" {
  for_each = var.api_type == "REST" ? var.api_keys : {}

  name        = "${local.api_name}-${each.key}"
  description = each.value.description != "" ? each.value.description : "API key for ${each.key}"
  enabled     = each.value.enabled

  tags = {
    Name = "${local.api_name}-${each.key}"
  }
}

# Usage Plans (REST API only)
resource "aws_api_gateway_usage_plan" "this" {
  for_each = var.api_type == "REST" ? var.usage_plans : {}

  name        = "${local.api_name}-${each.key}"
  description = each.value.description != "" ? each.value.description : "Usage plan for ${each.key}"

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }

  dynamic "quota_settings" {
    for_each = each.value.quota != null ? [each.value.quota] : []
    content {
      limit  = quota_settings.value.limit
      offset = quota_settings.value.offset
      period = quota_settings.value.period
    }
  }

  dynamic "throttle_settings" {
    for_each = each.value.throttle != null ? [each.value.throttle] : []
    content {
      burst_limit = throttle_settings.value.burst_limit
      rate_limit  = throttle_settings.value.rate_limit
    }
  }

  tags = {
    Name = "${local.api_name}-${each.key}"
  }
}

# Usage Plan Keys (REST API only)
resource "aws_api_gateway_usage_plan_key" "this" {
  for_each = var.api_type == "REST" ? merge([
    for plan_key, plan in var.usage_plans : {
      for api_key in plan.api_key_keys :
      "${plan_key}-${api_key}" => {
        usage_plan_key = plan_key
        api_key        = api_key
      }
    }
  ]...) : {}

  key_id        = aws_api_gateway_api_key.this[each.value.api_key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this[each.value.usage_plan_key].id
}
