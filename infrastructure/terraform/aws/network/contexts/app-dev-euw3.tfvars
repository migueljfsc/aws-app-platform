environment  = "dev"
service_name = "app"

vpc_cidr = "10.79.0.0/20"

availability_zones = ["eu-west-3a", "eu-west-3b"]

public_subnets = {
  "eu-west-3a" = [
    { cidr = "10.79.0.0/24" }
  ]
  "eu-west-3b" = [
    { cidr = "10.79.1.0/24" }
  ]
}

private_subnets = {
  "eu-west-3a" = [
    { cidr = "10.79.8.0/24" }
  ]
  "eu-west-3b" = [
    { cidr = "10.79.9.0/24" }
  ]
}

enable_nat_gateway = false

security_groups = {
  alb = {
    description = "Application Load Balancers"
  }
  ecs-fargate = {
    description = "ECS Fargate tasks"
  }
  ecs-ec2 = {
    description = "ECS EC2 container instances"
  }
  rds = {
    description = "RDS databases"
  }
  elasticache = {
    description = "ElastiCache"
  }
  vpc-endpoints = {
    description = "VPC Interface Endpoints"
  }
  cloudfront-alb = {
    description = "CloudFront access to ALB"
  }
}

ingress_rules = {
  # ====================================
  # CloudFront Ingress (ALB Access)
  # ====================================
  cloudfront_alb_https = {
    sg_key         = "cloudfront-alb"
    prefix_list_id = ""
    from_port      = 443
    to_port        = 443
    ip_protocol    = "tcp"
    description    = "HTTPS from CloudFront"
  }

  cloudfront_alb_http = {
    sg_key         = "cloudfront-alb"
    prefix_list_id = ""
    from_port      = 80
    to_port        = 80
    ip_protocol    = "tcp"
    description    = "HTTP from CloudFront"
  }

  # ====================================
  # ECS Fargate Ingress
  # ====================================
  fargate_from_alb = {
    sg_key        = "ecs-fargate"
    source_sg_key = "alb"
    from_port     = 0
    to_port       = 65535
    ip_protocol   = "tcp"
    description   = "All TCP from ALB"
  }

  # ====================================
  # ECS EC2 Ingress
  # ====================================
  ec2_from_alb = {
    sg_key        = "ecs-ec2"
    source_sg_key = "alb"
    from_port     = 0 # ECS dynamic port range
    to_port       = 65535
    ip_protocol   = "tcp"
    description   = "Dynamic ports from ALB for ECS tasks"
  }

  # ====================================
  # RDS Ingress
  # ====================================
  rds_from_fargate = {
    sg_key        = "rds"
    source_sg_key = "ecs-fargate"
    from_port     = 5432
    to_port       = 5432
    ip_protocol   = "tcp"
    description   = "PostgreSQL from Fargate tasks"
  }

  rds_from_ec2 = {
    sg_key        = "rds"
    source_sg_key = "ecs-ec2"
    from_port     = 5432
    to_port       = 5432
    ip_protocol   = "tcp"
    description   = "PostgreSQL from EC2 tasks"
  }

  # ====================================
  # Elasticache Ingress
  # ====================================
  elasticache_from_fargate = {
    sg_key        = "elasticache"
    source_sg_key = "ecs-fargate"
    from_port     = 6379
    to_port       = 6379
    ip_protocol   = "tcp"
    description   = "ElastiCache from Fargate tasks"
  }

  elasticache_from_ec2 = {
    sg_key        = "elasticache"
    source_sg_key = "ecs-ec2"
    from_port     = 6379
    to_port       = 6379
    ip_protocol   = "tcp"
    description   = "ElastiCache from EC2 tasks"
  }

  # ====================================
  # VPC Endpoints Ingress
  # ====================================
  vpc_endpoints_from_fargate = {
    sg_key        = "vpc-endpoints"
    source_sg_key = "ecs-fargate"
    from_port     = 443
    to_port       = 443
    ip_protocol   = "tcp"
    description   = "HTTPS from Fargate tasks"
  }

  vpc_endpoints_from_ec2 = {
    sg_key        = "vpc-endpoints"
    source_sg_key = "ecs-ec2"
    from_port     = 443
    to_port       = 443
    ip_protocol   = "tcp"
    description   = "HTTPS from EC2 tasks"
  }
}

egress_rules = {
  # ====================================
  # ALB Egress
  # ====================================
  alb_to_fargate = {
    sg_key      = "alb"
    cidr_ipv4   = "10.79.0.0/20"
    from_port   = 0
    to_port     = 65535
    ip_protocol = "tcp"
    description = "To ECS tasks in private subnets"
  }

  # ====================================
  # ECS Fargate Egress
  # ====================================
  fargate_https = {
    sg_key      = "ecs-fargate"
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    description = "HTTPS to internet (ECR, APIs, etc.)"
  }

  fargate_http = {
    sg_key      = "ecs-fargate"
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    description = "HTTP to internet"
  }

  fargate_to_rds = {
    sg_key      = "ecs-fargate"
    cidr_ipv4   = "10.79.0.0/20"
    from_port   = 5432
    to_port     = 5432
    ip_protocol = "tcp"
    description = "To RDS PostgreSQL"
  }

  fargate_to_elasticache = {
    sg_key      = "ecs-fargate"
    cidr_ipv4   = "10.79.0.0/20"
    from_port   = 6379
    to_port     = 6379
    ip_protocol = "tcp"
    description = "To ElastiCache"
  }

  # ====================================
  # ECS EC2 Egress
  # ====================================
  ec2_https = {
    sg_key      = "ecs-ec2"
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    description = "HTTPS to internet (ECR, APIs, etc.)"
  }

  ec2_http = {
    sg_key      = "ecs-ec2"
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    description = "HTTP to internet"
  }

  ec2_to_rds = {
    sg_key      = "ecs-ec2"
    cidr_ipv4   = "10.79.0.0/20"
    from_port   = 5432
    to_port     = 5432
    ip_protocol = "tcp"
    description = "To RDS PostgreSQL"
  }

  ec2_to_elasticache = {
    sg_key      = "ecs-ec2"
    cidr_ipv4   = "10.79.0.0/20"
    from_port   = 6379
    to_port     = 6379
    ip_protocol = "tcp"
    description = "To ElastiCache"
  }
}
