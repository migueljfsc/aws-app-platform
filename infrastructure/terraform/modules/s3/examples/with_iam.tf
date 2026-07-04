module "s3_app_data" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  enable_encryption  = true
  versioning_enabled = true

  create_iam_user      = true
  iam_user_name        = "myapp-upload-user"
  iam_user_permissions = ["read", "write", "list"]

  lifecycle_rules = {
    cleanup_old_versions = {
      enabled = true
      noncurrent_version_expiration = {
        noncurrent_days = 90
      }
    }
  }
}
