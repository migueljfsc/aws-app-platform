# WAF Association (REST API)
resource "aws_wafv2_web_acl_association" "rest" {
  resource_arn = "arn:aws:apigateway:${data.aws_region.current.region}::/apis/${aws_api_gateway_rest_api.this.id}/stages/${var.stage_name}"
  web_acl_arn  = data.aws_wafv2_web_acl.this.arn

  lifecycle {
    enabled = var.api_type == "REST" && var.attach_web_acl
  }
}
