# First public subnet per AZ (for NAT gateway placement)
locals {
  public_subnet_by_az = {
    for k, v in aws_subnet.public :
    v.availability_zone => v.id...
  }
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.service_name}-${var.environment}-igw"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  domain = "vpc"

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-nat-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.this]
}

# NAT Gateways
resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = local.public_subnet_by_az[var.availability_zones[count.index]][0]

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.this]
}
