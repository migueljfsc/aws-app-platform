resource "aws_security_group" "this" {
  name        = "${var.service_name}-${module.aws_registry.deploy_context}"
  description = "Security group for ${var.service_name}-${module.aws_registry.deploy_context}"
  vpc_id      = data.aws_vpc.this.id

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-sg"
  }
}

resource "aws_security_group_rule" "this" {
  for_each = var.security_group_rules

  security_group_id = aws_security_group.this.id
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  description       = lookup(each.value, "description", null)
}

resource "aws_security_group_rule" "external_inbound" {
  for_each = var.external_sg_inbound_rules

  type                     = "ingress"
  security_group_id        = data.aws_security_group.external[each.value.security_group_name].id
  source_security_group_id = aws_security_group.this.id

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  description = try(each.value.description, null)
}
