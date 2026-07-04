environment  = "dev"
service_name = "cloudfront"

# ==============================================================================
# Web ACL Configuration
# ==============================================================================
scope       = "CLOUDFRONT"
description = "WAF for CloudFront - blocks all by default, allows specific IP sets"

# ==============================================================================
# Rules
# ==============================================================================
rules = {
  # ---------------------------------------------------------------------------
  # AWS Managed Rule Groups (evaluated first)
  # ---------------------------------------------------------------------------

  # Core Rule Set — general web exploits (OWASP Top 10)
  aws-core-rules = {
    priority = 10
    action   = "none"

    statement = {
      managed_rule_group = {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }
  }

  # Known Bad Inputs — Log4j, SSRF, etc.
  aws-known-bad-inputs = {
    priority = 20
    action   = "none"

    statement = {
      managed_rule_group = {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }
  }

  # SQL Injection
  aws-sqli = {
    priority = 30
    action   = "none"

    statement = {
      managed_rule_group = {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
      }
    }
  }

  # Linux OS — path traversal, LFI
  aws-linux = {
    priority = 40
    action   = "none"

    statement = {
      managed_rule_group = {
        vendor_name = "AWS"
        name        = "AWSManagedRulesLinuxRuleSet"
      }
    }
  }

  # Amazon IP Reputation — known malicious IPs
  aws-ip-reputation = {
    priority = 50
    action   = "none"

    statement = {
      managed_rule_group = {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }
  }

  # Anonymous IP — VPNs, proxies, Tor
  aws-anonymous-ip = {
    priority = 60
    action   = "none"

    statement = {
      managed_rule_group = {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAnonymousIpList"
      }
    }
  }

  # ---------------------------------------------------------------------------
  # Final Allowlist
  # ---------------------------------------------------------------------------
  # Allowlist — allows trusted IPs IF they passed all AWS Managed Rules above
  app-allowlist = {
    priority = 100
    action   = "allow"

    statement = {
      ip_set = {
        ip_set_key = "app-allow"
      }
    }
  }
}

# ==============================================================================
# IP Sets (add addresses when ready)
# ==============================================================================
ip_sets = {
  app-allow = {
    scope              = "CLOUDFRONT"
    ip_address_version = "IPV4"
    description        = "Trusted IPs - allowed through WAF - Office IPs"
    addresses          = ["203.0.113.10/32"]
  }
}

# ==============================================================================
# CloudWatch Logging
# ==============================================================================
logging_configuration = {
  log_retention_in_days = 30

  redacted_fields = [
    { type = "single_header", data = "authorization" },
    { type = "single_header", data = "cookie" }
  ]
}
