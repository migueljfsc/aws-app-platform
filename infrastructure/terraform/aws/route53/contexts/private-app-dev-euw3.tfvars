environment  = "dev"
service_name = "private-app"

create_zone = true
zone_name   = "my.domain.com"
comment     = "Private zone for app"

private_zone = true

# records = {
#   dev = {
#     name    = "dev.my.domain.com"
#     type    = "A"
#     ttl     = 60
#     records = ["10.0.0.10"]
#   }
# }
