
environment  = "dev"
service_name = "app"

certificate_domain = "dev.my.domain.com"

aliases = ["dev.my.domain.com", "stg.my.domain.com"]
hosts = [
  {
    zone_name = "dev.my.domain.com"
  },
  {
    zone_name = "stg.my.domain.com"
  }
]

vpc_origins = {
  alb = {
    name                   = "app-dev-euw3-alb"
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "https-only"
    origin_ssl_protocols   = ["TLSv1.2"]
  }
}

origins = {
  alb = {
    origin_id   = "alb-origin"
    domain_name = "my.domain.com"
    vpc_origin_config = {
      vpc_origin_id = "alb"
    }
  }
}

default_cache_behavior = {
  target_origin_id         = "alb-origin"
  viewer_protocol_policy   = "redirect-to-https"
  allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
  cached_methods           = ["GET", "HEAD"]
  cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
  origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer
}

default_root_object = ""
