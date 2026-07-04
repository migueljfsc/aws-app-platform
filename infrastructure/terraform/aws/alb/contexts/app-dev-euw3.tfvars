environment  = "dev"
service_name = "app"

internal = true

hosts = [
  {
    zone_name = "dev.my.domain.com"
  },
  {
    zone_name = "stg.my.domain.com"
  }
]

http_listeners = {
  default = {
    port     = 80
    protocol = "HTTP"
    action = {
      type = "redirect"
      redirect = {
        status_code = "HTTP_301"
        protocol    = "HTTPS"
        port        = "443"
      }
    }
  }
}

https_listeners = {
  default = {
    port                = 443
    protocol            = "HTTPS"
    certificate_domains = ["dev.my.domain.com"]
    action = {
      type = "forward"
    }
  }
}
