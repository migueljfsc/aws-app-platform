# CloudWatch Log Group for WAF Logging
resource "aws_cloudwatch_log_group" "this" {
  name = "aws-waf-logs-${var.service_name}-${module.aws_registry.deploy_context}"

  retention_in_days = var.logging_configuration.log_retention_in_days

  tags = {
    Name = "aws-waf-logs-${var.service_name}-${module.aws_registry.deploy_context}"
  }

  lifecycle {
    enabled = var.logging_configuration != null
  }
}

# Logging Configuration
resource "aws_wafv2_web_acl_logging_configuration" "this" {
  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = ["${aws_cloudwatch_log_group.this.arn}:*"]

  dynamic "redacted_fields" {
    for_each = var.logging_configuration.redacted_fields
    content {
      dynamic "uri_path" {
        for_each = redacted_fields.value.type == "uri_path" ? [1] : []
        content {}
      }

      dynamic "query_string" {
        for_each = redacted_fields.value.type == "query_string" ? [1] : []
        content {}
      }

      dynamic "single_header" {
        for_each = redacted_fields.value.type == "single_header" ? [1] : []
        content {
          name = redacted_fields.value.data
        }
      }

      dynamic "method" {
        for_each = redacted_fields.value.type == "method" ? [1] : []
        content {}
      }
    }
  }

  dynamic "logging_filter" {
    for_each = var.logging_configuration.logging_filter != null ? [var.logging_configuration.logging_filter] : []
    content {
      default_behavior = logging_filter.value.default_behavior

      dynamic "filter" {
        for_each = logging_filter.value.filters
        content {
          behavior    = filter.value.behavior
          requirement = filter.value.requirement

          dynamic "condition" {
            for_each = filter.value.conditions
            content {
              dynamic "action_condition" {
                for_each = condition.value.action_condition != null ? [condition.value.action_condition] : []
                content {
                  action = action_condition.value.action
                }
              }

              dynamic "label_name_condition" {
                for_each = condition.value.label_name_condition != null ? [condition.value.label_name_condition] : []
                content {
                  label_name = label_name_condition.value.label_name
                }
              }
            }
          }
        }
      }
    }
  }

  lifecycle {
    enabled = var.logging_configuration != null
  }
}
