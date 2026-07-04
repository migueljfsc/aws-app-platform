# ALB Associations
resource "aws_wafv2_web_acl_association" "alb" {
  for_each = var.alb_associations

  resource_arn = data.aws_lb.this[each.key].arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# API Gateway Associations
resource "aws_wafv2_web_acl_association" "api_gateway" {
  for_each = var.api_gateway_associations

  resource_arn = data.aws_api_gateway_rest_api.this[each.key].arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
