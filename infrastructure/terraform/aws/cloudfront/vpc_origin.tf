resource "aws_cloudfront_vpc_origin" "this" {
  provider = aws.use1

  for_each = var.vpc_origins

  vpc_origin_endpoint_config {
    name                   = each.value.name
    arn                    = each.value.arn != "" ? each.value.arn : data.aws_lb.vpc_origins[each.key].arn
    http_port              = each.value.http_port
    https_port             = each.value.https_port
    origin_protocol_policy = each.value.origin_protocol_policy

    origin_ssl_protocols {
      items    = each.value.origin_ssl_protocols
      quantity = length(each.value.origin_ssl_protocols)
    }
  }

  tags = {
    Name = each.value.name
  }
}
