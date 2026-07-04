module "ecs_fargate" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  # Use an existing cluster
  cluster_name   = "myapp-dev-euw3-cluster"
  create_cluster = false

  # Basic configuration
  container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/webapp:v1.2.3"
  container_port  = 8080

  # Resources
  container_cpu    = 1024 # 1 vCPU
  container_memory = 2048 # 2 GB

  # Scaling
  desired_count                      = 5
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  # Application configuration
  container_environment_variables = {
    NODE_ENV    = "dev"
    PORT        = "8080"
    LOG_LEVEL   = "info"
    API_VERSION = "v1"
  }

  container_secrets = [
    {
      name      = "DATABASE_URL"
      valueFrom = "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/db-url-abc123"
    },
    {
      name      = "API_KEY"
      valueFrom = "arn:aws:ssm:us-east-1:123456789012:parameter/prod/api-key"
    },
    {
      name      = "JWT_SECRET"
      valueFrom = "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/jwt-secret-def456"
    }
  ]

  # Health check
  container_health_check = {
    command      = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
    interval     = 30
    timeout      = 5
    retries      = 3
    start_period = 60
  }

  # Networking
  assign_public_ip = false

  # Monitoring
  enable_execute_command    = true
  enable_container_insights = true

  # Target group integration
  target_groups = {
    webapp = {
      port        = 8080
      protocol    = "HTTP"
      target_type = "ip"

      health_check = {
        path                = "/health"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
        matcher             = "200"
      }

      stickiness = {
        enabled         = true
        type            = "lb_cookie"
        cookie_duration = 3600
      }
    }
  }

  # ALB listener rules
  alb_name = "internal"

  listener_rules = {
    default = {
      priority = 100
      conditions = [
        {
          path_pattern = ["/*"]
        }
      ]
    }
  }
}
