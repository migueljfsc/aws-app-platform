# ALB lookups by name
data "aws_lb" "this" {
  for_each = var.alb_associations

  name = "${each.key}-${module.aws_registry.deploy_context}-alb"
}

# API Gateway lookups by name
data "aws_api_gateway_rest_api" "this" {
  for_each = var.api_gateway_associations

  name = "${each.key}-${module.aws_registry.deploy_context}"
}
