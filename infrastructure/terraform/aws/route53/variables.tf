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
  description = "The name of the service (e.g., 'webapp', 'api', 'internal')"
  nullable    = false

  validation {
    condition     = var.service_name != ""
    error_message = "Service name cannot be empty."
  }
}

# ==============================================================================
# HOSTED ZONE CONFIGURATION
# ==============================================================================

variable "create_zone" {
  type        = bool
  default     = false
  description = "Create a new Route53 hosted zone (set to false to use an existing zone)"
  nullable    = false
}

variable "zone_name" {
  type        = string
  default     = ""
  description = "Domain name for the hosted zone (e.g., 'example.com' or 'internal.example.com'). Required if create_zone is true"
}

variable "private_zone" {
  type        = bool
  default     = false
  description = "Create a private hosted zone (accessible only from associated VPCs) instead of a public zone"
  nullable    = false
}

variable "comment" {
  type        = string
  default     = null
  description = "Comment to describe the hosted zone (defaults to 'Managed by Terraform - {deploy_context}' if not specified)"
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Allow destroying the hosted zone even if it contains records (use with caution)"
  nullable    = false
}

variable "delegation_set_id" {
  type        = string
  default     = ""
  description = "ID of a reusable delegation set to use for the hosted zone (for consistent nameservers across zones)"
}

# ==============================================================================
# VPC ASSOCIATION (Private Zones Only)
# ==============================================================================

variable "vpc_name" {
  type        = string
  default     = ""
  description = "Name of the VPC to associate with private hosted zone (defaults to '{deploy_context}-vpc' if empty). Only used when private_zone = true"
}

# ==============================================================================
# DNS RECORDS CONFIGURATION
# ==============================================================================

variable "records" {
  type = map(object({
    name    = string
    type    = string
    ttl     = optional(number)
    records = optional(list(string))
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = bool
    }))
    geolocation_routing_policy = optional(object({
      continent   = optional(string)
      country     = optional(string)
      subdivision = optional(string)
    }))
    latency_routing_policy = optional(object({
      region = string
    }))
    weighted_routing_policy = optional(object({
      weight = number
    }))
    failover_routing_policy = optional(object({
      type = string
    }))
    multivalue_answer_routing_policy = optional(bool, false)
    set_identifier                   = optional(string)
    health_check_id                  = optional(string)
    allow_overwrite                  = optional(bool, false)
  }))
  default     = {}
  description = "Map of DNS records to create in the hosted zone"
  nullable    = false
}

# ==============================================================================
# HEALTH CHECKS CONFIGURATION
# ==============================================================================

variable "health_checks" {
  type = map(object({
    type                            = string
    resource_path                   = optional(string)
    fqdn                            = optional(string)
    ip_address                      = optional(string)
    port                            = optional(number)
    protocol                        = optional(string)
    request_interval                = optional(number, 30)
    failure_threshold               = optional(number, 3)
    measure_latency                 = optional(bool, false)
    invert_healthcheck              = optional(bool, false)
    disabled                        = optional(bool, false)
    enable_sni                      = optional(bool, false)
    child_health_threshold          = optional(number)
    child_healthchecks              = optional(list(string))
    cloudwatch_alarm_name           = optional(string)
    cloudwatch_alarm_region         = optional(string)
    insufficient_data_health_status = optional(string, "Healthy")
    search_string                   = optional(string)
    regions                         = optional(list(string))
  }))
  default     = {}
  description = "Map of Route53 health checks to monitor endpoints (HTTP, HTTPS, TCP, or calculated checks)"
  nullable    = false
}

# ==============================================================================
# LOGGING CONFIGURATION
# ==============================================================================

variable "query_logging_config" {
  type = object({
    cloudwatch_log_group_arn = string
  })
  default     = null
  description = "CloudWatch Logs configuration for DNS query logging (logs all DNS queries received by Route53 for this zone)"
}

# ==============================================================================
# DNSSEC CONFIGURATION
# ==============================================================================

variable "dnssec_signing" {
  type = object({
    enabled = bool
  })
  default     = null
  description = "DNSSEC signing configuration to add cryptographic signatures to DNS responses (requires public hosted zone)"
}
