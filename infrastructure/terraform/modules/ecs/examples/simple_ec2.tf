module "ecs_simple_ec2" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  launch_type     = "EC2"
  container_image = "nginx:latest"

  # EC2-specific tags
  ec2_template_tags = {
    Application = "api-service"
    CostCenter  = "engineering"
    Backup      = "daily"
  }
}
