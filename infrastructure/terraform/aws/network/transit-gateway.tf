resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = data.aws_ec2_transit_gateway.this.id
  vpc_id             = aws_vpc.this.id

  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = {
    Name        = "${var.service_name}-${var.environment}-tgw-attach"
    Environment = var.environment
  }
}
