# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "this" {
  for_each = var.functions

  name              = "/aws/lambda/${var.service_name}-${var.deploy_context}-${each.key}"
  retention_in_days = each.value.log_retention_days

  tags = {
    Name = "${var.service_name}-${var.deploy_context}-${each.key}-logs"
  }
}
