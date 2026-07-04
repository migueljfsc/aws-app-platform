
resource "aws_db_parameter_group" "this" {
  name   = var.parameter_group_name
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = { Name = var.parameter_group_name }

  lifecycle {
    enabled               = var.parameter_group_name != ""
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "this" {
  name       = var.db_subnet_group_name != "" ? var.db_subnet_group_name : "${var.service_name}-${var.deploy_context}-db-subnet-group"
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.this.ids

  tags = {
    Name = var.db_subnet_group_name != "" ? var.db_subnet_group_name : "${var.service_name}-${var.deploy_context}-db-subnet-group"
  }
}
