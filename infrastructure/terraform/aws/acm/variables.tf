###################### MODULE VARIABLES ######################

# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================

variable "environment" {
  type        = string
  description = "The environment of the deployment (e.g. 'dev', 'stg')"
  nullable    = false
  validation {
    condition     = var.environment != ""
    error_message = "Module variable environment cannot be empty."
  }
}

variable "service_name" {
  type        = string
  description = "The name of the service"
  nullable    = false

  validation {
    condition     = var.service_name != ""
    error_message = "Service name cannot be empty."
  }
}

variable "region" {
  type        = string
  description = "The AWS region"
  default     = "eu-west-3"
  nullable    = false

  validation {
    condition     = var.region != ""
    error_message = "Region cannot be empty."
  }
}

# ==============================================================================
# CERTIFICATES
# ==============================================================================

variable "certificates" {
  type = map(object({
    domain_name               = string
    subject_alternative_names = optional(list(string), [])
    validation_method         = optional(string, "DNS")
    key_algorithm             = optional(string, "RSA_2048")

    # Certificate options
    certificate_transparency_logging = optional(string, "ENABLED")

    # Validation options
    validation_options = optional(list(object({
      domain_name       = string
      validation_domain = string
    })), [])

    # Route53 validation
    create_route53_records = optional(bool, true)
    route53_zone_id        = optional(string, "")
    route53_zone_name      = optional(string, "")
    route53_zone_private   = optional(bool, false)

    # Wait for validation
    wait_for_validation = optional(bool, true)

    # For CloudFront (must be in us-east-1)
    use_cloudfront_alias = optional(bool, false)

    tags = optional(map(string), {})
  }))
  description = "Map of ACM certificates to create"
  nullable    = false

  validation {
    condition = alltrue([
      for cert in var.certificates : contains(["DNS", "EMAIL"], cert.validation_method)
    ])
    error_message = "Validation method must be either DNS or EMAIL."
  }

  validation {
    condition = alltrue([
      for cert in var.certificates : contains([
        "RSA_1024", "RSA_2048", "RSA_3072", "RSA_4096",
        "EC_prime256v1", "EC_secp384r1", "EC_secp521r1"
      ], cert.key_algorithm)
    ])
    error_message = "Key algorithm must be one of: RSA_1024, RSA_2048, RSA_3072, RSA_4096, EC_prime256v1, EC_secp384r1, EC_secp521r1."
  }

  validation {
    condition = alltrue([
      for cert in var.certificates : contains(["ENABLED", "DISABLED"], cert.certificate_transparency_logging)
    ])
    error_message = "Certificate transparency logging must be either ENABLED or DISABLED."
  }
}


# ==============================================================================
# IMPORTED CERTIFICATES
# ==============================================================================

variable "imported_certificates" {
  type = map(object({
    certificate_body  = string
    private_key       = string
    certificate_chain = optional(string, "")

    tags = optional(map(string), {})
  }))
  default     = {}
  description = "Map of certificates to import (for self-signed or third-party certificates)"
  nullable    = false
}
