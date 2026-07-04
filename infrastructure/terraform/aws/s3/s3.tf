module "s3" {
  source = "../../modules/s3/"

  service_name   = var.service_name
  deploy_context = module.aws_registry.deploy_context

  bucket_name        = var.bucket_name
  force_destroy      = var.force_destroy
  versioning_enabled = var.versioning_enabled
  enable_encryption  = var.enable_encryption

  lifecycle_rules            = var.lifecycle_rules
  allowed_iam_arns           = var.allowed_iam_arns
  allowed_iam_permissions    = var.allowed_iam_permissions
  allowed_service_principals = var.allowed_service_principals
}
