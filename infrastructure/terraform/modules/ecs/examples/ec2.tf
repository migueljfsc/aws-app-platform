module "ecs_ec2" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  # Create cluster
  cluster_name   = "myapp-dev-euw3-cluster"
  create_cluster = true

  # Launch type
  launch_type  = "EC2"
  network_mode = "bridge" # EC2 supports bridge mode

  # Container configuration
  container_image             = "123456789012.dkr.ecr.us-east-1.amazonaws.com/api:latest"
  container_port              = 3000
  container_cpu               = 512  # Soft reservation per task
  container_memory            = 1024 # Soft reservation per task
  container_memory_hard_limit = 2048 # Hard limit (kills container if exceeded)

  # Application config
  container_environment_variables = {
    NODE_ENV  = "production"
    PORT      = "3000"
    LOG_LEVEL = "info"
    REGION    = "us-east-1"
  }

  container_secrets = [
    {
      name      = "DATABASE_URL"
      valueFrom = "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/db-url"
    }
  ]

  # Service scaling
  desired_count = 12 # 12 tasks across the cluster

  # EC2 Instance Configuration
  instance_type = "c5.2xlarge" # 8 vCPU, 16 GB RAM
  ami_id        = ""           # Use latest ECS-optimized AMI

  # Auto Scaling Group
  min_size         = 3  # Minimum 3 instances
  max_size         = 20 # Maximum 20 instances
  desired_capacity = 6  # Start with 6 instances (2 tasks per instance)

  # EBS Configuration
  root_volume_size      = 100 # 100 GB
  root_volume_type      = "gp3"
  root_volume_encrypted = true
  ebs_optimized         = true

  # Monitoring
  enable_monitoring         = true
  enable_asg_metrics        = true
  enable_container_insights = true
  enable_execute_command    = true

  # CloudWatch Logs
  enable_cloudwatch_logs        = true
  cloudwatch_log_retention_days = 30
  cloudwatch_log_stream_prefix  = "api"

  # CloudWatch Alarms
  enable_cloudwatch_alarms       = true
  cloudwatch_cpu_alarm_threshold = 80
  cloudwatch_alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:ecs-alerts"]

  # Capacity Provider Settings
  protect_from_scale_in     = false
  target_capacity           = 100 # Target 100% capacity utilization
  minimum_scaling_step_size = 1
  maximum_scaling_step_size = 10

  # Custom user data
  user_data_extra = <<-EOF
    # Install additional monitoring tools
    yum install -y amazon-cloudwatch-agent htop

    # Configure Docker logging
    echo '{"log-driver":"awslogs"}' > /etc/docker/daemon.json
    systemctl restart docker

    # Custom CloudWatch metrics
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config \
      -m ec2 \
      -s -c ssm:cloudwatch-config
  EOF

  # Target group for load balancing
  target_groups = {
    api = {
      port                          = 3000
      protocol                      = "HTTP"
      target_type                   = "instance" # EC2 uses instance target type
      deregistration_delay          = 30
      load_balancing_algorithm_type = "least_outstanding_requests"

      health_check = {
        path                = "/api/health"
        interval            = 15
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
        matcher             = "200-299"
      }
    }
  }

  # ALB listener rules
  alb_name = "internal"

  listener_rules = {
    api_route = {
      priority = 50
      conditions = [
        {
          path_pattern = ["/api/*"]
        }
      ]
    }
  }

  # EC2-specific tags
  ec2_template_tags = {
    Application = "api-service"
    CostCenter  = "engineering"
    Backup      = "daily"
  }
}
