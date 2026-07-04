service_name = "quotas"
environment  = "dev"

quota_increases = {
  # Rules per security group (default: 60)
  sg_rules = {
    service_code  = "vpc"
    quota_name    = "Inbound or outbound rules per security group"
    desired_value = 150
  }
}
