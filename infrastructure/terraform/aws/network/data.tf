data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

data "aws_ec2_transit_gateway" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.service_name}-${var.environment}-tgw"]
  }
}
