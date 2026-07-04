resource "aws_cloudfront_distribution" "this" {
  provider = aws.use1

  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = var.comment != "" ? var.comment : "${var.service_name}-${module.aws_registry.deploy_context}"
  default_root_object = var.default_root_object
  aliases             = length(var.aliases) > 0 ? var.aliases : (var.domain_name != "" ? [var.domain_name] : [])
  http_version        = var.http_version
  price_class         = var.price_class
  web_acl_id          = data.aws_wafv2_web_acl.this.arn
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment

  dynamic "origin" {
    for_each = var.origins
    content {
      domain_name         = origin.value.domain_name != "" ? origin.value.domain_name : var.domain_name
      origin_id           = origin.value.origin_id
      origin_path         = origin.value.origin_path
      connection_attempts = origin.value.connection_attempts
      connection_timeout  = origin.value.connection_timeout

      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [origin.value.custom_origin_config] : []
        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = custom_origin_config.value.origin_keepalive_timeout
          origin_read_timeout      = custom_origin_config.value.origin_read_timeout
        }
      }

      dynamic "s3_origin_config" {
        for_each = origin.value.s3_origin_config != null ? [origin.value.s3_origin_config] : []
        content {
          origin_access_identity = s3_origin_config.value.origin_access_identity
        }
      }

      dynamic "vpc_origin_config" {
        for_each = origin.value.vpc_origin_config != null ? [origin.value.vpc_origin_config] : []
        content {
          vpc_origin_id            = try(aws_cloudfront_vpc_origin.this[vpc_origin_config.value.vpc_origin_id].id, vpc_origin_config.value.vpc_origin_id)
          origin_keepalive_timeout = vpc_origin_config.value.origin_keepalive_timeout
          origin_read_timeout      = vpc_origin_config.value.origin_read_timeout
        }
      }

      dynamic "custom_header" {
        for_each = origin.value.custom_headers
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

      dynamic "origin_shield" {
        for_each = origin.value.origin_shield != null ? [origin.value.origin_shield] : []
        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.origin_shield_region
        }
      }
    }
  }

  default_cache_behavior {
    target_origin_id           = var.default_cache_behavior.target_origin_id
    viewer_protocol_policy     = var.default_cache_behavior.viewer_protocol_policy
    allowed_methods            = var.default_cache_behavior.allowed_methods
    cached_methods             = var.default_cache_behavior.cached_methods
    compress                   = var.default_cache_behavior.compress
    cache_policy_id            = var.default_cache_behavior.cache_policy_id
    origin_request_policy_id   = var.default_cache_behavior.origin_request_policy_id
    response_headers_policy_id = var.default_cache_behavior.response_headers_policy_id
    realtime_log_config_arn    = var.default_cache_behavior.realtime_log_config_arn
    smooth_streaming           = var.default_cache_behavior.smooth_streaming
    field_level_encryption_id  = var.default_cache_behavior.field_level_encryption_id

    dynamic "forwarded_values" {
      for_each = var.default_cache_behavior.forwarded_values != null ? [var.default_cache_behavior.forwarded_values] : []
      content {
        query_string = forwarded_values.value.query_string
        headers      = forwarded_values.value.headers

        cookies {
          forward           = forwarded_values.value.cookies.forward
          whitelisted_names = forwarded_values.value.cookies.whitelisted_names
        }
      }
    }

    min_ttl     = var.default_cache_behavior.min_ttl
    default_ttl = var.default_cache_behavior.default_ttl
    max_ttl     = var.default_cache_behavior.max_ttl

    dynamic "function_association" {
      for_each = var.default_cache_behavior.function_association
      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }

    dynamic "lambda_function_association" {
      for_each = var.default_cache_behavior.lambda_function_association
      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lambda_function_association.value.include_body
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      path_pattern               = ordered_cache_behavior.value.path_pattern
      target_origin_id           = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy     = ordered_cache_behavior.value.viewer_protocol_policy
      allowed_methods            = ordered_cache_behavior.value.allowed_methods
      cached_methods             = ordered_cache_behavior.value.cached_methods
      compress                   = ordered_cache_behavior.value.compress
      cache_policy_id            = ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id   = ordered_cache_behavior.value.origin_request_policy_id
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_id
      realtime_log_config_arn    = ordered_cache_behavior.value.realtime_log_config_arn
      smooth_streaming           = ordered_cache_behavior.value.smooth_streaming
      field_level_encryption_id  = ordered_cache_behavior.value.field_level_encryption_id

      dynamic "forwarded_values" {
        for_each = ordered_cache_behavior.value.forwarded_values != null ? [ordered_cache_behavior.value.forwarded_values] : []
        content {
          query_string = forwarded_values.value.query_string
          headers      = forwarded_values.value.headers

          cookies {
            forward           = forwarded_values.value.cookies.forward
            whitelisted_names = forwarded_values.value.cookies.whitelisted_names
          }
        }
      }

      min_ttl     = ordered_cache_behavior.value.min_ttl
      default_ttl = ordered_cache_behavior.value.default_ttl
      max_ttl     = ordered_cache_behavior.value.max_ttl

      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.function_association
        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }

      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_association
        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lambda_function_association.value.include_body
        }
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.certificate_domain == ""
    acm_certificate_arn            = var.certificate_domain != "" ? data.aws_acm_certificate.this.arn : null
    minimum_protocol_version       = var.certificate_domain != "" ? var.minimum_protocol_version : null
    ssl_support_method             = var.certificate_domain != "" ? var.ssl_support_method : null
  }

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-cloudfront"
  }
}
