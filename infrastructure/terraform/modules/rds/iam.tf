# Enhanced Monitoring Role
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.service_name}-${var.deploy_context}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.service_name}-${var.deploy_context}-rds-monitoring-role"
  }

  lifecycle {
    enabled = local.create_monitoring_role
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"

  lifecycle {
    enabled = local.create_monitoring_role
  }
}
