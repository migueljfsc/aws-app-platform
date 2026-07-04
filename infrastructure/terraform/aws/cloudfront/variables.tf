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
  description = "The name of the service (e.g., 'webapp', 'cdn', 'static-site')"
  nullable    = false

  validation {
    condition     = var.service_name != ""
    error_message = "Service name cannot be empty."
  }
}

variable "origins" {
  type = map(object({
    domain_name         = optional(string, "")
    origin_id           = string
    origin_path         = optional(string, "")
    connection_attempts = optional(number, 3)
    connection_timeout  = optional(number, 10)
    custom_origin_config = optional(object({
      http_port                = number
      https_port               = number
      origin_protocol_policy   = string
      origin_ssl_protocols     = list(string)
      origin_keepalive_timeout = optional(number, 5)
      origin_read_timeout      = optional(number, 30)
    }), null)
    s3_origin_config = optional(object({
      origin_access_identity = string
    }), null)
    vpc_origin_config = optional(object({
      vpc_origin_id            = string
      origin_keepalive_timeout = optional(number, 5)
      origin_read_timeout      = optional(number, 30)
    }), null)
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    origin_shield = optional(object({
      enabled              = bool
      origin_shield_region = string
    }), null)
  }))
  description = "Map of origin configurations (ALB, S3, or custom origins). At least one origin is required"
  nullable    = false

  validation {
    condition     = length(var.origins) > 0
    error_message = "At least one origin must be defined."
  }
}

variable "vpc_origins" {
  type = map(object({
    name                   = string
    arn                    = optional(string, "")
    http_port              = optional(number, 80)
    https_port             = optional(number, 443)
    origin_protocol_policy = optional(string, "https-only")
    origin_ssl_protocols   = optional(list(string), ["TLSv1.2"])
  }))
  default     = {}
  description = "Map of VPC origin configurations for connecting CloudFront to private resources (e.g., internal ALBs). Each entry creates an aws_cloudfront_vpc_origin resource"
  nullable    = false

  validation {
    condition = alltrue([
      for vo in var.vpc_origins : contains(["http-only", "https-only", "match-viewer"], vo.origin_protocol_policy)
    ])
    error_message = "VPC origin protocol policy must be one of: http-only, https-only, match-viewer."
  }
}

variable "default_cache_behavior" {
  type = object({
    target_origin_id           = string
    viewer_protocol_policy     = string
    allowed_methods            = list(string)
    cached_methods             = list(string)
    compress                   = optional(bool, true)
    cache_policy_id            = optional(string, "")
    origin_request_policy_id   = optional(string, "")
    response_headers_policy_id = optional(string, "")
    realtime_log_config_arn    = optional(string, "")
    smooth_streaming           = optional(bool, false)
    field_level_encryption_id  = optional(string, "")
    forwarded_values = optional(object({
      query_string = bool
      headers      = optional(list(string), [])
      cookies = object({
        forward           = string
        whitelisted_names = optional(list(string), [])
      })
    }), null)
    min_ttl     = optional(number, 0)
    default_ttl = optional(number, 0)
    max_ttl     = optional(number, 0)
    function_association = optional(list(object({
      event_type   = string
      function_arn = string
    })), [])
    lambda_function_association = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool, false)
    })), [])
  })
  description = "Default cache behavior for requests that don't match ordered cache behaviors"
  nullable    = false

  validation {
    condition = contains(
      ["allow-all", "https-only", "redirect-to-https"],
      var.default_cache_behavior.viewer_protocol_policy
    )
    error_message = "Viewer protocol policy must be one of: allow-all, https-only, redirect-to-https."
  }
}

# ==============================================================================
# DISTRIBUTION CONFIGURATION
# ==============================================================================

variable "domain_name" {
  type        = string
  default     = ""
  description = "The primary domain name for the CloudFront distribution (e.g. dev.example.com). Used as default for aliases, route53 records, and origin domain."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Enable the CloudFront distribution (set to false to disable without destroying)"
  nullable    = false
}

variable "comment" {
  type        = string
  default     = ""
  description = "Comment to describe the distribution (defaults to '{deploy_context}-{service_name}' if empty)"
}

variable "aliases" {
  type        = list(string)
  default     = []
  description = "Alternate domain names (CNAMEs) for the distribution (e.g., ['example.com', 'www.example.com'])"
  nullable    = false
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = "Object to return when a user requests the root URL (e.g., 'index.html' for static websites)"
  nullable    = false
}

variable "is_ipv6_enabled" {
  type        = bool
  default     = true
  description = "Enable IPv6 support for the distribution"
  nullable    = false
}

variable "http_version" {
  type        = string
  default     = "http2and3"
  description = "Maximum HTTP version to support (http1.1, http2, http2and3, http3)"
  nullable    = false

  validation {
    condition     = contains(["http1.1", "http2", "http2and3", "http3"], var.http_version)
    error_message = "HTTP version must be one of: http1.1, http2, http2and3, http3."
  }
}

variable "price_class" {
  type        = string
  default     = "PriceClass_100"
  description = "Price class for edge locations (PriceClass_100 = US/EU, PriceClass_200 = + Asia/Africa, PriceClass_All = all edge locations)"
  nullable    = false

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.price_class)
    error_message = "Price class must be one of: PriceClass_All, PriceClass_200, PriceClass_100."
  }
}

variable "retain_on_delete" {
  type        = bool
  default     = false
  description = "Disable the distribution instead of deleting it when Terraform destroy is run"
  nullable    = false
}

variable "wait_for_deployment" {
  type        = bool
  default     = true
  description = "Wait for distribution deployment to complete (can take 15-20 minutes)"
  nullable    = false
}

# ==============================================================================
# CACHE BEHAVIORS
# ==============================================================================

variable "ordered_cache_behaviors" {
  type = map(object({
    path_pattern               = string
    target_origin_id           = string
    viewer_protocol_policy     = string
    allowed_methods            = list(string)
    cached_methods             = list(string)
    compress                   = optional(bool, true)
    cache_policy_id            = optional(string, "")
    origin_request_policy_id   = optional(string, "")
    response_headers_policy_id = optional(string, "")
    realtime_log_config_arn    = optional(string, "")
    smooth_streaming           = optional(bool, false)
    field_level_encryption_id  = optional(string, "")
    forwarded_values = optional(object({
      query_string = bool
      headers      = optional(list(string), [])
      cookies = object({
        forward           = string
        whitelisted_names = optional(list(string), [])
      })
    }), null)
    min_ttl     = optional(number, 0)
    default_ttl = optional(number, 3600)
    max_ttl     = optional(number, 86400)
    function_association = optional(list(object({
      event_type   = string
      function_arn = string
    })), [])
    lambda_function_association = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool, false)
    })), [])
  }))
  default     = {}
  description = "Path-based cache behaviors for routing specific paths to different origins (e.g., /api/* to API origin)"
  nullable    = false
}

# ==============================================================================
# ERROR HANDLING
# ==============================================================================

variable "custom_error_responses" {
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number, 10)
  }))
  default     = []
  description = "Custom error page configurations (e.g., return /index.html for 404 errors on SPAs)"
  nullable    = false
}

# ==============================================================================
# GEOGRAPHIC RESTRICTIONS
# ==============================================================================

variable "geo_restriction_type" {
  type        = string
  default     = "none"
  description = "Type of geographic restriction (none, whitelist, blacklist)"
  nullable    = false

  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.geo_restriction_type)
    error_message = "Geo restriction type must be one of: none, whitelist, blacklist."
  }
}

variable "geo_restriction_locations" {
  type        = list(string)
  default     = []
  description = "List of ISO 3166-1-alpha-2 country codes for geo restriction (e.g., ['US', 'CA', 'GB'])"
  nullable    = false

  validation {
    condition = alltrue([
      for code in var.geo_restriction_locations : can(regex("^[A-Z]{2}$", code))
    ])
    error_message = "All country codes must be 2-letter uppercase ISO 3166-1-alpha-2 codes."
  }
}

# ==============================================================================
# SSL/TLS CONFIGURATION
# ==============================================================================

variable "certificate_domain" {
  type        = string
  default     = ""
  description = "The domain name to lookup the ACM certificate. Specify this if using a custom viewer certificate."
}

variable "minimum_protocol_version" {
  type        = string
  default     = "TLSv1.2_2021"
  description = "Minimum TLS version for HTTPS connections"
  nullable    = false

  validation {
    condition = contains([
      "TLSv1", "TLSv1_2016", "TLSv1.1_2016", "TLSv1.2_2018", "TLSv1.2_2019",
      "TLSv1.2_2021", "TLSv1.3_2021"
    ], var.minimum_protocol_version)
    error_message = "Minimum protocol version must be a valid CloudFront TLS policy."
  }
}

variable "ssl_support_method" {
  type        = string
  default     = "sni-only"
  description = "SSL support method (sni-only is free, vip costs $600/month)"
  nullable    = false

  validation {
    condition     = contains(["sni-only", "vip"], var.ssl_support_method)
    error_message = "SSL support method must be either sni-only or vip."
  }
}


# ==============================================================================
# ROUTE53 CONFIGURATION
# ==============================================================================
variable "hosts" {
  type = list(object({
    zone_name              = string
    host                   = optional(string, "")
    evaluate_target_health = optional(bool, false)
  }))

  default     = []
  description = "Hosts with their zone names"
  nullable    = false
}

# ==============================================================================
# LOGGING CONFIGURATION
# ==============================================================================
variable "log_retention_days" {
  type        = number
  default     = 30
  description = "Number of days to retain CloudFront logs"
  nullable    = false
}


# ==============================================================================
# WAF CONFIGURATION
# ==============================================================================

variable "web_acl_name" {
  type        = string
  default     = ""
  description = "Name of AWS WAF Web ACL to associate with the distribution (for DDoS protection and security rules)"
}
