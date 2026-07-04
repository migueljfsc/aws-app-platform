locals {
  # Determine launch type
  is_fargate = var.launch_type == "FARGATE"
  is_ec2     = var.launch_type == "EC2"

  cluster_name    = var.cluster_name != "" ? var.cluster_name : "${var.service_name}-${var.deploy_context}-cluster"
  container_image = var.container_image != "" ? var.container_image : "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.region}.amazonaws.com/${var.service_name}"
}

# ==============================================================================
# ECS CLUSTER
# ==============================================================================
resource "aws_ecs_cluster" "this" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = {
    Name = local.cluster_name
  }

  lifecycle {
    enabled = var.create_cluster
  }
}

# ==============================================================================
# ECS TASK
# ==============================================================================
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.service_name}-${var.deploy_context}-task"
  network_mode             = var.network_mode
  requires_compatibilities = local.is_fargate ? ["FARGATE"] : ["EC2"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = data.aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.this.arn

  container_definitions = jsonencode([
    {
      name = var.service_name
      # On first run define the image, otherwise use the previous image to avoid terraform drift
      image     = "${local.container_image}:${var.container_image_tag}"
      essential = true

      # CPU and Memory - handled differently per launch type
      # EC2: soft reservation (can be omitted for EC2, but including doesn't break it)
      # Fargate: not set at container level (set at task level instead)
      cpu               = local.is_ec2 ? var.container_cpu : null
      memoryReservation = local.is_ec2 ? var.container_memory : null
      memory            = local.is_ec2 ? (var.container_memory_hard_limit != null ? var.container_memory_hard_limit : null) : null

      portMappings = [
        {
          containerPort = var.container_port
          # hostPort:
          # - EC2: 0 for dynamic port mapping (required for ALB)
          # - Fargate: omit
          hostPort = local.is_ec2 ? 0 : null
          protocol = "tcp"
        }
      ]

      environment = [
        for key, value in var.container_environment_variables : {
          name  = key
          value = value
        }
      ]

      secrets = var.container_secrets

      logConfiguration = var.enable_cloudwatch_logs ? {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.current.region
          "awslogs-stream-prefix" = var.cloudwatch_log_stream_prefix
        }
      } : null

      # Health check - optional for both
      healthCheck = var.container_health_check != null ? {
        command     = var.container_health_check.command
        interval    = var.container_health_check.interval
        timeout     = var.container_health_check.timeout
        retries     = var.container_health_check.retries
        startPeriod = var.container_health_check.start_period
      } : null

      # EC2 only (not supported in Fargate)
      privileged = local.is_ec2 ? var.container_privileged : null

      # Fargate only (not supported in EC2)
      resourceRequirements = local.is_fargate && var.container_resource_requirements != null ? var.container_resource_requirements : null

      # Works fine for both EC2 and Fargate
      mountPoints            = var.container_mount_points
      ulimits                = var.container_ulimits
      user                   = var.container_user
      workingDirectory       = var.container_working_directory
      entryPoint             = var.container_entrypoint
      command                = var.container_command
      extraHosts             = var.container_extra_hosts
      hostname               = var.container_hostname
      dnsServers             = var.container_dns_servers
      dnsSearchDomains       = var.container_dns_search_domains
      dockerLabels           = var.container_docker_labels
      systemControls         = var.container_system_controls
      linuxParameters        = var.container_linux_parameters
      readonlyRootFilesystem = var.container_readonly_rootfs
      interactive            = var.container_interactive
      pseudoTerminal         = var.container_pseudo_terminal
      firelensConfiguration  = var.container_firelens_configuration
      dependsOn              = var.container_depends_on
    }
  ])

  tags = {
    Name = "${var.service_name}-${var.deploy_context}-task"
  }
}

# ==============================================================================
# ECS SERVICE
# ==============================================================================
resource "aws_ecs_service" "this" {
  name            = "${var.service_name}-${var.deploy_context}-service"
  cluster         = var.create_cluster ? aws_ecs_cluster.this.id : data.aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = local.is_fargate ? "FARGATE" : null

  force_new_deployment = true

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [1] : []
    content {
      subnets          = data.aws_subnets.this.ids
      security_groups  = data.aws_security_groups.this.ids
      assign_public_ip = var.assign_public_ip
    }
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn != "" ? [var.target_group_arn] : [for tg in values(aws_lb_target_group.this) : tg.arn]

    content {
      target_group_arn = load_balancer.value
      container_name   = var.service_name
      container_port   = var.container_port
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = local.is_ec2 ? [1] : []
    content {
      capacity_provider = aws_ecs_capacity_provider.this.name
      weight            = 1
    }
  }

  enable_execute_command = var.enable_execute_command

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  tags = {
    Name = "${var.service_name}-${var.deploy_context}-service"
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = local.is_fargate ? ["FARGATE", "FARGATE_SPOT"] : [aws_ecs_capacity_provider.this.name]

  dynamic "default_capacity_provider_strategy" {
    for_each = local.is_fargate ? [1] : []
    content {
      capacity_provider = "FARGATE"
      weight            = 1
    }
  }

  dynamic "default_capacity_provider_strategy" {
    for_each = local.is_ec2 ? [1] : []
    content {
      capacity_provider = aws_ecs_capacity_provider.this.name
      weight            = 1
    }
  }
}
