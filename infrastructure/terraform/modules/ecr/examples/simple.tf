module "ecr" {
  source = "../"

  service_name = "myapp"

  # Allow ECS task roles to pull
  allowed_principals = [
    "arn:aws:iam::123456789012:role/ecs-task-role-myapp",
    "arn:aws:iam::123456789012:role/ecs-task-role-dev"
  ]

  # Allow another AWS account to pull
  allowed_account_ids = [
    "app" # Dev account
  ]
}
