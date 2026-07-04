# VPC Link (for HTTP API private integrations)
resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "${local.api_name}-vpc-link"
  security_group_ids = var.vpc_link_security_group_ids
  subnet_ids         = var.vpc_link_subnet_ids

  tags = {
    Name = "${local.api_name}-vpc-link"
  }

  lifecycle {
    enabled = var.api_type == "HTTP" && var.create_vpc_link
  }
}

# VPC Link (for REST API private integrations)
resource "aws_api_gateway_vpc_link" "this" {
  name        = "${local.api_name}-vpc-link"
  target_arns = [] # For REST API, you need NLB target ARNs

  tags = {
    Name = "${local.api_name}-vpc-link"
  }

  lifecycle {
    enabled = var.api_type == "REST" && var.create_vpc_link
  }
}
