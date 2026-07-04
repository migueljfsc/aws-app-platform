module "ecs_on_ec2" {
  source = "../../../../../infrastructure/terraform/modules/ecs"

  shared_deploy_context = module.aws_registry.shared_deploy_context
  deploy_context        = module.aws_registry.deploy_context
  service_name          = var.service_name

  # ECS
  launch_type            = "EC2"
  create_cluster         = true
  enable_execute_command = true

  # Container
  desired_count               = var.desired_count
  container_port              = 3000
  container_image             = local.ecr_image
  container_image_tag         = var.container_image_tag
  container_cpu               = 1024
  container_memory            = 750
  container_memory_hard_limit = 750

  container_environment_variables = {
    ENV                 = var.environment,
    NEXT_PUBLIC_APP_URL = "https://${var.environment}.my.domain.com",
    NEXT_PUBLIC_API_URL = "https://api.${var.environment}.my.domain.com/v1"
    REDIS_URL           = "redis://${module.redis.dns_record}:${module.redis.port}"
  }

  container_secrets = [
    { name = "MY_SECRET", valueFrom = "${aws_secretsmanager_secret.this.arn}:MY_SECRET::" }
  ]

  # Instance config
  network_mode = "bridge"

  # Auto Scaling Group
  min_size         = 1 # Minimum 1 instance
  max_size         = 3 # Maximum 3 instances
  desired_capacity = 1 # Start with 1 instance (2 task per instance)

  # Cloudwatch
  cloudwatch_log_retention_days = var.cloudwatch_log_retention_days

  # ALB
  alb_name = var.alb_name

  target_groups = {
    http = {
      port        = 3000
      protocol    = "HTTP"
      target_type = "instance"
      health_check = {
        path = "/health"
      }
    }
  }

  listener_rules = {
    http = {
      priority = local.listener_rule_priorities[var.environment]
      conditions = [
        {
          host_header = ["${var.environment}.my.domain.com"]
        }
      ]
    }
  }

  ec2_template_tags = module.aws_registry.tags
}


resource "aws_secretsmanager_secret" "this" {
  name = "${var.service_name}-${module.aws_registry.deploy_context}"
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = "placeholder"

  lifecycle {
    ignore_changes = [secret_string]
  }
}
