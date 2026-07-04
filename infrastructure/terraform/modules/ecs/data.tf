data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = var.vpc_name != "" ? [var.vpc_name] : ["app-${var.deploy_context}-vpc"]
  }
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_security_groups" "this" {
  filter {
    name   = "tag:Name"
    values = length(var.security_group_names) > 0 ? var.security_group_names : [local.is_ec2 ? "app-${var.deploy_context}-ecs-ec2" : "app-${var.deploy_context}-ecs-fargate"]
  }
}

data "aws_ecs_cluster" "this" {
  cluster_name = local.cluster_name

  lifecycle {
    enabled = var.create_cluster == false
  }
}

data "aws_iam_role" "ecs_execution" {
  name = "ecs-task-execution"
}

data "aws_iam_instance_profile" "this" {
  name = "ec2-app-server"
}

data "aws_lb" "this" {
  name = "${var.alb_name}-${var.deploy_context}-alb"

  lifecycle {
    enabled = var.alb_name != ""
  }
}

data "aws_lb_listener" "this_https" {
  load_balancer_arn = data.aws_lb.this.arn
  port              = 443
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-*-x86_64"]
  }

  lifecycle {
    enabled = local.is_ec2 && var.ami_id == ""
  }
}
