

service_name = "app-api"
environment  = "dev"

api_type = "HTTP"

stage_name = "dev"

# CORS for frontend
cors_configuration = {
  allow_origins     = ["https://dev.my.domain.com", "http://localhost:3000"]
  allow_methods     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  allow_headers     = ["Content-Type", "Authorization"]
  max_age           = 300
  allow_credentials = true
}

# Cognito auth
cognito_authorizers = {
  cognito-main = {
    issuer           = "https://cognito-idp.eu-west-3.amazonaws.com/eu-west-3_7xULZ3GhY"
    audience         = ["3c90op5f84kebss2tt1epe7mf4"]
    identity_sources = ["$request.header.Authorization"]
  }
}

# Custom domain
create_custom_domain    = true
certificate_domain_name = "dev.my.domain.com"
domain_name             = "api.dev.my.domain.com"
base_path               = "v1"

# Route53
create_route53_record = true
route53_zone_name     = "dev.my.domain.com"

# Disable default endpoint
disable_execute_api_endpoint = true

# Logging
enable_access_logging = true

# Monitoring
# enable_metrics = true
# enable_tracing = true
