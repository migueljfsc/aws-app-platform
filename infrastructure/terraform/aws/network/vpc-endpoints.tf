resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${module.aws_registry.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids  = [aws_security_group.this["vpc-endpoints"].id]
  private_dns_enabled = true

  tags = {
    Name = "${var.service_name}-${var.environment}-vpce-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${module.aws_registry.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids  = [aws_security_group.this["vpc-endpoints"].id]
  private_dns_enabled = true

  tags = {
    Name = "${var.service_name}-${var.environment}-vpce-ecr-api"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${module.aws_registry.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt in aws_route_table.private : rt.id]

  tags = {
    Name = "${var.service_name}-${var.environment}-vpce-s3"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${module.aws_registry.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids  = [aws_security_group.this["vpc-endpoints"].id]
  private_dns_enabled = true

  tags = {
    Name = "${var.service_name}-${var.environment}-vpce-logs"
  }
}

import {
  to = aws_vpc_endpoint.s3
  id = "vpce-06d67bf2224956547"
}
