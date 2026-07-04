resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = "${var.service_name}-${module.aws_registry.deploy_context}-${each.key}"
  description = "Security group for ${each.value.description}"
  vpc_id      = aws_vpc.this.id


  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-${each.key}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.ingress_rules

  description = try(each.value.description, null)

  security_group_id            = aws_security_group.this[each.value.sg_key].id
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.source_sg_key != null ? aws_security_group.this[each.value.source_sg_key].id : null
  prefix_list_id = (
    each.value.prefix_list_id != ""
    ? each.value.prefix_list_id
    : strcontains(each.key, "cloudfront") ? data.aws_ec2_managed_prefix_list.cloudfront.id : null
  )

  from_port   = try(each.value.from_port, null)
  to_port     = try(each.value.to_port, null)
  ip_protocol = each.value.ip_protocol
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.egress_rules

  description = try(each.value.description, null)

  security_group_id = aws_security_group.this[each.value.sg_key].id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = try(each.value.from_port, null)
  to_port           = try(each.value.to_port, null)
  ip_protocol       = each.value.ip_protocol
}
