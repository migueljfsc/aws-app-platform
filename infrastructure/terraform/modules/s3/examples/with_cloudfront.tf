module "s3_website" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  website_configuration = {
    index_document = "index.html"
    error_document = "error.html"
  }

  create_cloudfront_oai = true

  cors_rules = [
    {
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://example.com"]
      allowed_headers = ["*"]
      max_age_seconds = 3000
    }
  ]
}
