locals {
  public_subnets_flat = flatten([
    for az, subs in var.public_subnets : [
      for idx, s in subs : {
        az   = az
        cidr = s.cidr
        name = s.name != "" ? s.name : "subnet-public${idx + 1}"
      }
    ]
  ])

  private_subnets_flat = flatten([
    for az, subs in var.private_subnets : [
      for idx, s in subs : {
        az   = az
        cidr = s.cidr
        name = s.name != "" ? s.name : "subnet-private${idx + 1}"
      }
    ]
  ])
}

###################### PUBLIC SUBNETS ######################
resource "aws_subnet" "public" {
  for_each = {
    for s in local.public_subnets_flat :
    "${var.service_name}-${var.environment}-${s.name}-${s.az}" => s
  }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.service_name}-${var.environment}-${each.value.name}-${each.value.az}"
    Type = "public"
    AZ   = each.value.az
  }
}


###################### PRIVATE SUBNETS ######################
resource "aws_subnet" "private" {
  for_each = {
    for s in local.private_subnets_flat :
    "${var.service_name}-${var.environment}-${s.name}-${s.az}" => s
  }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.service_name}-${var.environment}-${each.value.name}-${each.value.az}"
    Type = "private"
    AZ   = each.value.az
  }
}
