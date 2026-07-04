resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name                          = "${var.service_name}-${each.key}-${var.deploy_context}-tg"
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
    Name = "${var.service_name}-${each.key}-${var.deploy_context}-tg"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb_listener_rule" "this" {
  for_each = var.listener_rules

  listener_arn = data.aws_lb_listener.this_https.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
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
    Name = "${var.service_name}-${each.key}-${var.deploy_context}-rule"
  }
}
