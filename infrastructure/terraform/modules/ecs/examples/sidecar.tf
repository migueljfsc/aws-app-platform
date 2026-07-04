module "ecs_sidecar" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  # Main application container
  container_image  = "123456789012.dkr.ecr.us-east-1.amazonaws.com/webapp:latest"
  container_port   = 8080
  container_cpu    = 256
  container_memory = 512

  container_environment_variables = {
    APP_NAME = "webapp"
  }

  # Container dependencies (starts after sidecar)
  container_depends_on = [
    {
      containerName = "datadog-agent"
      condition     = "START"
    }
  ]

  # EC2 configuration
  instance_type    = "m5.large"
  min_size         = 2
  max_size         = 8
  desired_capacity = 4

  desired_count = 8 # 2 tasks per instance

  # EC2-specific tags
  ec2_template_tags = {
    Application = "api-service"
    CostCenter  = "engineering"
    Backup      = "daily"
  }
}
