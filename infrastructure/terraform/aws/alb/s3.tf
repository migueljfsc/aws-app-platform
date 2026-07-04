module "s3_logs" {
  source = "../../modules/s3/"

  service_name   = var.service_name
  deploy_context = module.aws_registry.deploy_context

  bucket_name = "${var.service_name}-${module.aws_registry.deploy_context}-alb-logs"

  enable_encryption  = true
  versioning_enabled = true

  allowed_service_principals = [{
    identifier = "logdelivery.elasticloadbalancing.amazonaws.com"
    actions    = ["s3:PutObject"]
    source_arn = aws_lb.this.arn
  }]

  lifecycle {
    enabled = var.access_logs_enabled
  }
}
