module "ecs_simple_fargate" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  container_image = "nginx:latest"
}
