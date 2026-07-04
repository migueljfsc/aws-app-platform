environment  = "dev"
service_name = "public-app"

create_zone = true
zone_name   = "my.domain.com"
comment     = "Public zone for app"

private_zone = false

# records = {
#   dev = {
#     name    = "dev.my.domain.com"
#     type    = "A"
#     ttl     = 60
#     records = ["1.2.3.4"]
#   }
# }
