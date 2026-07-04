
###################### MODULE VARIABLES ######################

# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================
variable "environment" {
  type        = string
  description = "The environment of the deployment (e.g. 'dev', 'stg')"
  nullable    = false
  validation {
    condition     = var.environment != ""
    error_message = "Module variable environment cannot be empty."
  }
}

variable "service_name" {
  type        = string
  description = "The name of the service (e.g., 'webapp', 'api', 'cdn')"
  nullable    = false

  validation {
    condition     = var.service_name != ""
    error_message = "Service name cannot be empty."
  }
}

# ==============================================================================
# WEB ACL CONFIGURATION
# ==============================================================================

variable "scope" {
  type        = string
  description = "The scope of the Web ACL (REGIONAL or CLOUDFRONT)"
  nullable    = false

  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "Scope must be either REGIONAL or CLOUDFRONT."
  }
}

variable "default_action" {
  type        = string
  description = "The default action for the Web ACL (allow or block)"
  default     = "block"
  nullable    = false

  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "Default action must be either allow or block."
  }
}

variable "description" {
  type        = string
  description = "Description for the Web ACL"
  default     = ""
}

variable "custom_response_body" {
  type = map(object({
    content      = string
    content_type = string
  }))
  default     = {}
  description = "Custom response bodies for the Web ACL"
  nullable    = false
}

variable "sampled_requests_enabled" {
  type        = bool
  description = "Whether to enable sampled requests for the Web ACL"
  default     = true
}

variable "cloudwatch_metrics_enabled" {
  type        = bool
  description = "Whether to enable CloudWatch metrics for the Web ACL"
  default     = true
}

variable "metric_name" {
  type        = string
  description = "Custom metric name for the Web ACL. Defaults to service_name-deploy_context"
  default     = ""
}

variable "token_domains" {
  type        = list(string)
  description = "Token domains for CAPTCHA/Challenge"
  default     = []
}

# ==============================================================================
# WAF RULES
# ==============================================================================

variable "rules" {
  type = map(object({
    priority = number
    action   = string # allow, block, count, captcha, challenge, none (for managed groups)

    # Rule statement
    statement = object({
      # Managed rule group
      managed_rule_group = optional(object({
        vendor_name = string
        name        = string
        version     = optional(string)
        rule_action_overrides = optional(list(object({
          name   = string
          action = string
        })), [])
      }))

      # Rate-based rule
      rate_based = optional(object({
        limit              = number
        aggregate_key_type = optional(string, "IP")
        forwarded_ip_config = optional(object({
          header_name       = string
          fallback_behavior = string
        }))
      }))

      # IP set
      ip_set = optional(object({
        arn               = optional(string) # External IP set ARN
        ip_set_key        = optional(string) # Key from var.ip_sets (module-created)
        ip_header_name    = optional(string)
        fallback_behavior = optional(string, "NO_MATCH")
        position          = optional(string, "FIRST")
      }))

      # Geo match
      geo_match = optional(object({
        country_codes = list(string)
        forwarded_ip_config = optional(object({
          header_name       = string
          fallback_behavior = string
        }))
      }))

      # Byte match
      byte_match = optional(object({
        search_string         = string
        positional_constraint = string
        field_to_match = object({
          type = string
          data = optional(string)
        })
        text_transformations = list(object({
          priority = number
          type     = string
        }))
      }))

      # Size constraint
      size_constraint = optional(object({
        comparison_operator = string
        size                = number
        field_to_match = object({
          type = string
          data = optional(string)
        })
        text_transformations = list(object({
          priority = number
          type     = string
        }))
      }))

      # SQL injection
      sqli_match = optional(object({
        field_to_match = object({
          type = string
          data = optional(string)
        })
        text_transformations = list(object({
          priority = number
          type     = string
        }))
      }))

      # XSS match
      xss_match = optional(object({
        field_to_match = object({
          type = string
          data = optional(string)
        })
        text_transformations = list(object({
          priority = number
          type     = string
        }))
      }))

      # Regex pattern set
      regex_pattern_set = optional(object({
        arn                   = optional(string) # External regex pattern set ARN
        regex_pattern_set_key = optional(string) # Key from var.regex_pattern_sets (module-created)
        field_to_match = object({
          type = string
          data = optional(string)
        })
        text_transformations = list(object({
          priority = number
          type     = string
        }))
      }))

      # Label match
      label_match = optional(object({
        scope = string
        key   = string
      }))
    })

    # Rule labels
    rule_labels = optional(list(string), [])

    # Visibility
    cloudwatch_metrics_enabled = optional(bool, true)
    sampled_requests_enabled   = optional(bool, true)
    metric_name                = optional(string, "")

    # Custom response
    custom_response = optional(object({
      response_code            = number
      custom_response_body_key = optional(string)
      response_headers = optional(list(object({
        name  = string
        value = string
      })), [])
    }))

    # CAPTCHA configuration
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }))
  }))
  default     = {}
  description = "Map of WAF rules to create"
  nullable    = false

  validation {
    condition = alltrue([
      for rule in var.rules : contains(["allow", "block", "count", "captcha", "challenge", "none"], rule.action)
    ])
    error_message = "Rule action must be one of: allow, block, count, captcha, challenge, none."
  }

  validation {
    condition = alltrue([
      for rule in var.rules : rule.priority >= 0 && rule.priority <= 1000
    ])
    error_message = "Rule priority must be between 0 and 1000."
  }
}

# ==============================================================================
# IP SETS
# ==============================================================================

variable "ip_sets" {
  type = map(object({
    scope              = string # REGIONAL or CLOUDFRONT
    ip_address_version = optional(string, "IPV4")
    addresses          = list(string)
    description        = optional(string, "")
    tags               = optional(map(string), {})
  }))
  default     = {}
  description = "Map of IP sets to create (for allowlists or blocklists)"
  nullable    = false

  validation {
    condition = alltrue([
      for ipset in var.ip_sets : contains(["REGIONAL", "CLOUDFRONT"], ipset.scope)
    ])
    error_message = "IP set scope must be either REGIONAL or CLOUDFRONT."
  }

  validation {
    condition = alltrue([
      for ipset in var.ip_sets : contains(["IPV4", "IPV6"], ipset.ip_address_version)
    ])
    error_message = "IP address version must be either IPV4 or IPV6."
  }
}

# ==============================================================================
# REGEX PATTERN SETS
# ==============================================================================

variable "regex_pattern_sets" {
  type = map(object({
    scope       = string # REGIONAL or CLOUDFRONT
    description = optional(string, "")
    patterns = list(object({
      regex = string
    }))
    tags = optional(map(string), {})
  }))
  default     = {}
  description = "Map of regex pattern sets to create"
  nullable    = false

  validation {
    condition = alltrue([
      for regex_set in var.regex_pattern_sets : contains(["REGIONAL", "CLOUDFRONT"], regex_set.scope)
    ])
    error_message = "Regex pattern set scope must be either REGIONAL or CLOUDFRONT."
  }
}

# ==============================================================================
# LOGGING CONFIGURATION
# ==============================================================================

variable "logging_configuration" {
  type = object({
    log_retention_in_days = optional(number, 30)
    redacted_fields = optional(list(object({
      type = string
      data = optional(string)
    })), [])
    logging_filter = optional(object({
      default_behavior = string
      filters = list(object({
        behavior    = string
        requirement = string
        conditions = list(object({
          action_condition = optional(object({
            action = string
          }))
          label_name_condition = optional(object({
            label_name = string
          }))
        }))
      }))
    }))
  })
  default     = null
  description = "Logging configuration for the Web ACL. When set, creates a CloudWatch Log Group with the aws-waf-logs- prefix."
}

# ==============================================================================
# RESOURCE ASSOCIATIONS
# ==============================================================================

variable "alb_associations" {
  type        = map(string)
  default     = {}
  description = "Map of ALB associations (key => ALB name). ARN is resolved via data source."
  nullable    = false
}

variable "api_gateway_associations" {
  type        = map(string)
  default     = {}
  description = "Map of API Gateway associations (key => stage name). API name is derived as key-deploy_context."
  nullable    = false
}
