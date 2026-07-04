module "s3_private" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  enable_encryption  = true
  versioning_enabled = true
}
