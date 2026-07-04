module "s3_with_role_access" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  enable_encryption  = true
  versioning_enabled = true

  # Grant bucket access to existing IAM roles (e.g., ECS task roles, Lambda execution roles)
  allowed_iam_arns        = ["arn:aws:iam::123456789012:role/my-ecs-task-role"]
  allowed_iam_permissions = ["read", "write", "list"]
}
