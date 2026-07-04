locals {
  zone_id = var.create_zone ? aws_route53_zone.this.zone_id : data.aws_route53_zone.this.id
}

resource "aws_route53_zone" "this" {
  name              = var.zone_name
  comment           = var.comment
  force_destroy     = var.force_destroy
  delegation_set_id = var.private_zone ? null : var.delegation_set_id

  dynamic "vpc" {
    for_each = var.private_zone ? [1] : []
    content {
      vpc_id = data.aws_vpc.this.id
    }
  }

  tags = {
    Name = var.zone_name
  }

  lifecycle {
    enabled = var.create_zone
  }
}


resource "aws_route53_record" "this" {
  for_each = var.records

  zone_id         = local.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = each.value.alias == null ? each.value.ttl : null
  records         = each.value.alias == null ? each.value.records : null
  set_identifier  = each.value.set_identifier
  health_check_id = each.value.health_check_id
  allow_overwrite = each.value.allow_overwrite

  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = each.value.geolocation_routing_policy != null ? [each.value.geolocation_routing_policy] : []
    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }

  dynamic "latency_routing_policy" {
    for_each = each.value.latency_routing_policy != null ? [each.value.latency_routing_policy] : []
    content {
      region = latency_routing_policy.value.region
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = each.value.weighted_routing_policy != null ? [each.value.weighted_routing_policy] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  dynamic "failover_routing_policy" {
    for_each = each.value.failover_routing_policy != null ? [each.value.failover_routing_policy] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  multivalue_answer_routing_policy = each.value.multivalue_answer_routing_policy
}

resource "aws_route53_health_check" "this" {
  for_each = var.health_checks

  type                            = each.value.type
  resource_path                   = each.value.resource_path
  fqdn                            = each.value.fqdn
  ip_address                      = each.value.ip_address
  port                            = each.value.port
  request_interval                = each.value.request_interval
  failure_threshold               = each.value.failure_threshold
  measure_latency                 = each.value.measure_latency
  invert_healthcheck              = each.value.invert_healthcheck
  disabled                        = each.value.disabled
  enable_sni                      = each.value.enable_sni
  child_health_threshold          = each.value.child_health_threshold
  child_healthchecks              = each.value.child_healthchecks
  cloudwatch_alarm_name           = each.value.cloudwatch_alarm_name
  cloudwatch_alarm_region         = each.value.cloudwatch_alarm_region
  insufficient_data_health_status = each.value.insufficient_data_health_status
  search_string                   = each.value.search_string
  regions                         = each.value.regions

  tags = {
    Name = "${each.value.fqdn}-hc"
  }
}

resource "aws_route53_query_log" "this" {
  zone_id                  = local.zone_id
  cloudwatch_log_group_arn = var.query_logging_config.cloudwatch_log_group_arn

  lifecycle {
    enabled = var.query_logging_config != null
  }
}

resource "aws_route53_hosted_zone_dnssec" "this" {
  hosted_zone_id = local.zone_id

  lifecycle {
    enabled = var.create_zone && var.dnssec_signing != null && var.dnssec_signing.enabled
  }
}
