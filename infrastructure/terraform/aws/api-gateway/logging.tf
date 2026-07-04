# CloudWatch Log Group for Access Logs
resource "aws_cloudwatch_log_group" "access_logs" {
  name              = "/aws/apigateway/${local.api_name}/access-logs"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = {
    Name = "${local.api_name}-access-logs"
  }

  lifecycle {
    enabled = var.enable_access_logging
  }
}

# CloudWatch Log Group for Execution Logs (REST API only)
resource "aws_cloudwatch_log_group" "execution_logs" {
  name              = "/aws/apigateway/${local.api_name}/execution-logs"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = {
    Name = "${local.api_name}-execution-logs"
  }

  lifecycle {
    enabled = var.api_type == "REST" && var.enable_execution_logging
  }
}
