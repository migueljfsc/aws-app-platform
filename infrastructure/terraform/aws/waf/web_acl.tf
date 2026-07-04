# Web ACL
resource "aws_wafv2_web_acl" "this" {
  name        = "${var.service_name}-${module.aws_registry.deploy_context}"
  description = var.description != "" ? var.description : "Web ACL for ${var.service_name}"
  scope       = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  # Rules
  dynamic "rule" {
    for_each = var.rules

    content {
      name     = replace(rule.key, "_", "-")
      priority = rule.value.priority

      # override_action for managed rule groups
      dynamic "override_action" {
        for_each = rule.value.statement.managed_rule_group != null ? [1] : []
        content {
          dynamic "none" {
            for_each = rule.value.action != "count" ? [1] : []
            content {}
          }
          dynamic "count" {
            for_each = rule.value.action == "count" ? [1] : []
            content {}
          }
        }
      }

      # Action for custom rules (not managed rule groups)
      dynamic "action" {
        for_each = rule.value.statement.managed_rule_group == null && rule.value.action == "allow" ? [1] : []
        content {
          allow {}
        }
      }

      dynamic "action" {
        for_each = rule.value.statement.managed_rule_group == null && rule.value.action == "block" ? [1] : []
        content {
          block {
            dynamic "custom_response" {
              for_each = rule.value.custom_response != null ? [rule.value.custom_response] : []
              content {
                response_code            = custom_response.value.response_code
                custom_response_body_key = custom_response.value.custom_response_body_key

                dynamic "response_header" {
                  for_each = custom_response.value.response_headers
                  content {
                    name  = response_header.value.name
                    value = response_header.value.value
                  }
                }
              }
            }
          }
        }
      }

      dynamic "action" {
        for_each = rule.value.statement.managed_rule_group == null && rule.value.action == "count" ? [1] : []
        content {
          count {}
        }
      }

      dynamic "action" {
        for_each = rule.value.statement.managed_rule_group == null && rule.value.action == "captcha" ? [1] : []
        content {
          captcha {
            dynamic "custom_request_handling" {
              for_each = rule.value.captcha_config != null ? [1] : []
              content {
                insert_header {
                  name  = "x-captcha-required"
                  value = "true"
                }
              }
            }
          }
        }
      }

      dynamic "action" {
        for_each = rule.value.statement.managed_rule_group == null && rule.value.action == "challenge" ? [1] : []
        content {
          challenge {}
        }
      }

      # Statement
      statement {
        # Managed rule group
        dynamic "managed_rule_group_statement" {
          for_each = rule.value.statement.managed_rule_group != null ? [rule.value.statement.managed_rule_group] : []
          content {
            vendor_name = managed_rule_group_statement.value.vendor_name
            name        = managed_rule_group_statement.value.name
            version     = managed_rule_group_statement.value.version

            dynamic "rule_action_override" {
              for_each = managed_rule_group_statement.value.rule_action_overrides
              content {
                name = rule_action_override.value.name
                action_to_use {
                  dynamic "allow" {
                    for_each = rule_action_override.value.action == "allow" ? [1] : []
                    content {}
                  }
                  dynamic "block" {
                    for_each = rule_action_override.value.action == "block" ? [1] : []
                    content {}
                  }
                  dynamic "count" {
                    for_each = rule_action_override.value.action == "count" ? [1] : []
                    content {}
                  }
                }
              }
            }
          }
        }

        # Rate-based rule
        dynamic "rate_based_statement" {
          for_each = rule.value.statement.rate_based != null ? [rule.value.statement.rate_based] : []
          content {
            limit              = rate_based_statement.value.limit
            aggregate_key_type = rate_based_statement.value.aggregate_key_type

            dynamic "forwarded_ip_config" {
              for_each = rate_based_statement.value.forwarded_ip_config != null ? [rate_based_statement.value.forwarded_ip_config] : []
              content {
                header_name       = forwarded_ip_config.value.header_name
                fallback_behavior = forwarded_ip_config.value.fallback_behavior
              }
            }
          }
        }

        # IP set
        dynamic "ip_set_reference_statement" {
          for_each = rule.value.statement.ip_set != null ? [rule.value.statement.ip_set] : []
          content {
            arn = ip_set_reference_statement.value.ip_set_key != null ? aws_wafv2_ip_set.this[ip_set_reference_statement.value.ip_set_key].arn : ip_set_reference_statement.value.arn

            dynamic "ip_set_forwarded_ip_config" {
              for_each = ip_set_reference_statement.value.ip_header_name != null ? [1] : []
              content {
                header_name       = ip_set_reference_statement.value.ip_header_name
                fallback_behavior = ip_set_reference_statement.value.fallback_behavior
                position          = ip_set_reference_statement.value.position
              }
            }
          }
        }

        # Geo match
        dynamic "geo_match_statement" {
          for_each = rule.value.statement.geo_match != null ? [rule.value.statement.geo_match] : []
          content {
            country_codes = geo_match_statement.value.country_codes

            dynamic "forwarded_ip_config" {
              for_each = geo_match_statement.value.forwarded_ip_config != null ? [geo_match_statement.value.forwarded_ip_config] : []
              content {
                header_name       = forwarded_ip_config.value.header_name
                fallback_behavior = forwarded_ip_config.value.fallback_behavior
              }
            }
          }
        }

        # Byte match
        dynamic "byte_match_statement" {
          for_each = rule.value.statement.byte_match != null ? [rule.value.statement.byte_match] : []
          content {
            search_string         = byte_match_statement.value.search_string
            positional_constraint = byte_match_statement.value.positional_constraint

            field_to_match {
              dynamic "uri_path" {
                for_each = byte_match_statement.value.field_to_match.type == "uri_path" ? [1] : []
                content {}
              }

              dynamic "query_string" {
                for_each = byte_match_statement.value.field_to_match.type == "query_string" ? [1] : []
                content {}
              }

              dynamic "body" {
                for_each = byte_match_statement.value.field_to_match.type == "body" ? [1] : []
                content {}
              }

              dynamic "method" {
                for_each = byte_match_statement.value.field_to_match.type == "method" ? [1] : []
                content {}
              }

              dynamic "single_header" {
                for_each = byte_match_statement.value.field_to_match.type == "single_header" ? [1] : []
                content {
                  name = byte_match_statement.value.field_to_match.data
                }
              }
            }

            dynamic "text_transformation" {
              for_each = byte_match_statement.value.text_transformations
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        # Size constraint
        dynamic "size_constraint_statement" {
          for_each = rule.value.statement.size_constraint != null ? [rule.value.statement.size_constraint] : []
          content {
            comparison_operator = size_constraint_statement.value.comparison_operator
            size                = size_constraint_statement.value.size

            field_to_match {
              dynamic "uri_path" {
                for_each = size_constraint_statement.value.field_to_match.type == "uri_path" ? [1] : []
                content {}
              }

              dynamic "query_string" {
                for_each = size_constraint_statement.value.field_to_match.type == "query_string" ? [1] : []
                content {}
              }

              dynamic "body" {
                for_each = size_constraint_statement.value.field_to_match.type == "body" ? [1] : []
                content {}
              }

              dynamic "method" {
                for_each = size_constraint_statement.value.field_to_match.type == "method" ? [1] : []
                content {}
              }

              dynamic "single_header" {
                for_each = size_constraint_statement.value.field_to_match.type == "single_header" ? [1] : []
                content {
                  name = size_constraint_statement.value.field_to_match.data
                }
              }
            }

            dynamic "text_transformation" {
              for_each = size_constraint_statement.value.text_transformations
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        # SQL injection
        dynamic "sqli_match_statement" {
          for_each = rule.value.statement.sqli_match != null ? [rule.value.statement.sqli_match] : []
          content {
            field_to_match {
              dynamic "uri_path" {
                for_each = sqli_match_statement.value.field_to_match.type == "uri_path" ? [1] : []
                content {}
              }

              dynamic "query_string" {
                for_each = sqli_match_statement.value.field_to_match.type == "query_string" ? [1] : []
                content {}
              }

              dynamic "body" {
                for_each = sqli_match_statement.value.field_to_match.type == "body" ? [1] : []
                content {}
              }

              dynamic "single_header" {
                for_each = sqli_match_statement.value.field_to_match.type == "single_header" ? [1] : []
                content {
                  name = sqli_match_statement.value.field_to_match.data
                }
              }
            }

            dynamic "text_transformation" {
              for_each = sqli_match_statement.value.text_transformations
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        # XSS match
        dynamic "xss_match_statement" {
          for_each = rule.value.statement.xss_match != null ? [rule.value.statement.xss_match] : []
          content {
            field_to_match {
              dynamic "uri_path" {
                for_each = xss_match_statement.value.field_to_match.type == "uri_path" ? [1] : []
                content {}
              }

              dynamic "query_string" {
                for_each = xss_match_statement.value.field_to_match.type == "query_string" ? [1] : []
                content {}
              }

              dynamic "body" {
                for_each = xss_match_statement.value.field_to_match.type == "body" ? [1] : []
                content {}
              }

              dynamic "single_header" {
                for_each = xss_match_statement.value.field_to_match.type == "single_header" ? [1] : []
                content {
                  name = xss_match_statement.value.field_to_match.data
                }
              }
            }

            dynamic "text_transformation" {
              for_each = xss_match_statement.value.text_transformations
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        # Regex pattern set
        dynamic "regex_pattern_set_reference_statement" {
          for_each = rule.value.statement.regex_pattern_set != null ? [rule.value.statement.regex_pattern_set] : []
          content {
            arn = regex_pattern_set_reference_statement.value.regex_pattern_set_key != null ? aws_wafv2_regex_pattern_set.this[regex_pattern_set_reference_statement.value.regex_pattern_set_key].arn : regex_pattern_set_reference_statement.value.arn

            field_to_match {
              dynamic "uri_path" {
                for_each = regex_pattern_set_reference_statement.value.field_to_match.type == "uri_path" ? [1] : []
                content {}
              }

              dynamic "query_string" {
                for_each = regex_pattern_set_reference_statement.value.field_to_match.type == "query_string" ? [1] : []
                content {}
              }

              dynamic "body" {
                for_each = regex_pattern_set_reference_statement.value.field_to_match.type == "body" ? [1] : []
                content {}
              }

              dynamic "single_header" {
                for_each = regex_pattern_set_reference_statement.value.field_to_match.type == "single_header" ? [1] : []
                content {
                  name = regex_pattern_set_reference_statement.value.field_to_match.data
                }
              }
            }

            dynamic "text_transformation" {
              for_each = regex_pattern_set_reference_statement.value.text_transformations
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        # Label match
        dynamic "label_match_statement" {
          for_each = rule.value.statement.label_match != null ? [rule.value.statement.label_match] : []
          content {
            scope = label_match_statement.value.scope
            key   = label_match_statement.value.key
          }
        }
      }

      # Visibility
      visibility_config {
        cloudwatch_metrics_enabled = rule.value.cloudwatch_metrics_enabled
        sampled_requests_enabled   = rule.value.sampled_requests_enabled
        metric_name                = rule.value.metric_name != "" ? rule.value.metric_name : rule.key
      }

      # Rule labels
      dynamic "rule_label" {
        for_each = rule.value.rule_labels
        content {
          name = rule_label.value
        }
      }
    }
  }

  # Custom response bodies
  dynamic "custom_response_body" {
    for_each = var.custom_response_body
    content {
      key          = custom_response_body.key
      content      = custom_response_body.value.content
      content_type = custom_response_body.value.content_type
    }
  }

  # Token domains for CAPTCHA/Challenge
  token_domains = length(var.token_domains) > 0 ? var.token_domains : null

  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    sampled_requests_enabled   = var.sampled_requests_enabled
    metric_name                = var.metric_name != "" ? var.metric_name : "${var.service_name}-${module.aws_registry.deploy_context}"
  }

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}"
  }
}
