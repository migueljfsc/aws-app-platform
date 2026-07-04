resource "aws_lb" "this" {
  load_balancer_type = "application"

  name = "${var.service_name}-${module.aws_registry.deploy_context}-alb"

  internal        = var.internal
  security_groups = data.aws_security_groups.this.ids
  subnets         = data.aws_subnets.this.ids

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  idle_timeout                     = var.idle_timeout
  drop_invalid_header_fields       = var.drop_invalid_header_fields
  enable_waf_fail_open             = var.enable_waf_fail_open

  dynamic "access_logs" {
    for_each = var.access_logs_enabled ? [1] : []
    content {
      bucket  = module.s3_logs.bucket_id
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = {
    Name     = "${var.service_name}-${module.aws_registry.deploy_context}-alb"
    Internal = var.internal
    Type     = "alb"
  }
}

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name                          = "${var.service_name}-${module.aws_registry.deploy_context}-${each.key}-tg"
  port                          = each.value.port
  protocol                      = each.value.protocol
  vpc_id                        = data.aws_vpc.this.id
  target_type                   = each.value.target_type
  deregistration_delay          = each.value.deregistration_delay
  slow_start                    = each.value.slow_start
  load_balancing_algorithm_type = each.value.load_balancing_algorithm_type

  health_check {
    enabled             = each.value.health_check.enabled
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    timeout             = each.value.health_check.timeout
    interval            = each.value.health_check.interval
    path                = each.value.health_check.path
    port                = each.value.health_check.port
    protocol            = each.value.health_check.protocol
    matcher             = each.value.health_check.matcher
  }

  dynamic "stickiness" {
    for_each = each.value.stickiness != null ? [each.value.stickiness] : []
    content {
      enabled         = stickiness.value.enabled
      type            = stickiness.value.type
      cookie_duration = stickiness.value.cookie_duration
      cookie_name     = stickiness.value.cookie_name != "" ? stickiness.value.cookie_name : null
    }
  }

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-${each.key}-tg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  for_each = var.http_listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type = (
      each.value.action.type == "forward"
      && !contains(keys(var.target_groups), each.value.action.target_group_key)
    ) ? "fixed-response" : each.value.action.type

    dynamic "redirect" {
      for_each = each.value.action.redirect != null ? [each.value.action.redirect] : []
      content {
        port        = redirect.value.port
        protocol    = redirect.value.protocol
        status_code = redirect.value.status_code
      }
    }

    dynamic "fixed_response" {
      for_each = (
        each.value.action.type == "forward"
        && !contains(keys(var.target_groups), each.value.action.target_group_key)
        ) ? [{ content_type = "text/plain", message_body = "No target group configured", status_code = "503" }] : (
        each.value.action.fixed_response != null ? [each.value.action.fixed_response] : []
      )
      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }

    target_group_arn = (
      each.value.action.type == "forward"
      && contains(keys(var.target_groups), each.value.action.target_group_key)
    ) ? aws_lb_target_group.this[each.value.action.target_group_key].arn : null
  }


  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-${each.key}-http"
  }
}

resource "aws_lb_listener" "https" {
  for_each = var.https_listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.ssl_policy
  certificate_arn   = data.aws_acm_certificate.this[each.value.certificate_domains[0]].arn

  default_action {
    type = (
      each.value.action.type == "forward"
      && !contains(keys(var.target_groups), each.value.action.target_group_key)
    ) ? "fixed-response" : each.value.action.type

    dynamic "redirect" {
      for_each = each.value.action.redirect != null ? [each.value.action.redirect] : []
      content {
        port        = redirect.value.port
        protocol    = redirect.value.protocol
        status_code = redirect.value.status_code
      }
    }

    dynamic "fixed_response" {
      for_each = (
        each.value.action.type == "forward"
        && !contains(keys(var.target_groups), each.value.action.target_group_key)
        ) ? [{ content_type = "text/plain", message_body = "No target group configured", status_code = "503" }] : (
        each.value.action.fixed_response != null ? [each.value.action.fixed_response] : []
      )
      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }

    target_group_arn = (
      each.value.action.type == "forward"
      && contains(keys(var.target_groups), each.value.action.target_group_key)
    ) ? aws_lb_target_group.this[each.value.action.target_group_key].arn : null
  }

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-${each.key}-https"
  }
}

resource "aws_lb_listener_rule" "this" {
  for_each = var.listener_rules

  listener_arn = try(
    aws_lb_listener.https[each.value.listener_key].arn,
    aws_lb_listener.http[each.value.listener_key].arn
  )
  priority = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  }

  dynamic "condition" {
    for_each = each.value.conditions
    content {
      dynamic "path_pattern" {
        for_each = length(condition.value.path_pattern) > 0 ? [condition.value.path_pattern] : []
        content {
          values = path_pattern.value
        }
      }

      dynamic "host_header" {
        for_each = length(condition.value.host_header) > 0 ? [condition.value.host_header] : []
        content {
          values = host_header.value
        }
      }

      dynamic "http_header" {
        for_each = condition.value.http_header != null ? [condition.value.http_header] : []
        content {
          http_header_name = http_header.value.name
          values           = http_header.value.values
        }
      }

      dynamic "query_string" {
        for_each = length(condition.value.query_string) > 0 ? condition.value.query_string : []
        content {
          key   = query_string.value.key != "" ? query_string.value.key : null
          value = query_string.value.value
        }
      }

      dynamic "source_ip" {
        for_each = length(condition.value.source_ip) > 0 ? [condition.value.source_ip] : []
        content {
          values = source_ip.value
        }
      }
    }
  }

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-${each.key}-rule"
  }
}

resource "aws_lb_listener_certificate" "this" {
  for_each = local.additional_listener_certificates

  listener_arn = aws_lb_listener.https[each.value.listener_key].arn

  certificate_arn = data.aws_acm_certificate.this[each.value.domain].arn
}
