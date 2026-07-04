###################### MODULE VARIABLES ######################

# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================
variable "service_name" {
  type        = string
  description = "The name of the service (e.g., 'webapp', 'api', 'platform')"
  nullable    = false

  validation {
    condition     = var.service_name != ""
    error_message = "Service name cannot be empty."
  }
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., 'prod', 'staging', 'dev')"
  nullable    = false

  validation {
    condition     = var.environment != ""
    error_message = "Environment cannot be empty."
  }
}

# ==============================================================================
# VPC CONFIGURATION
# ==============================================================================

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC (e.g., '10.0.0.0/16' for 65,536 IP addresses)"
  nullable    = false

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block (e.g., '10.0.0.0/16')."
  }
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "Enable DNS hostnames in the VPC (required for ECS, RDS, and other services)"
  nullable    = false
}

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "Enable DNS resolution in the VPC (required for most AWS services)"
  nullable    = false
}

# ==============================================================================
# AVAILABILITY ZONES & SUBNETS
# ==============================================================================

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for subnet distribution (e.g., ['eu-west-1a', 'eu-west-1b', 'eu-west-1c'])"
  nullable    = false

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones are required for high availability."
  }
}

variable "public_subnets" {
  type = map(list(object({
    cidr = string
    name = optional(string, "")
  })))

  description = "Map of availability zone to public subnet definition"

  nullable = false

  validation {
    condition     = length(var.public_subnets) >= 2
    error_message = "At least 2 public subnets are required (one per availability zone)."
  }

  validation {
    condition = alltrue(flatten([
      for subs in values(var.public_subnets) : [
        for s in subs : can(cidrhost(s.cidr, 0))
      ]
    ]))
    error_message = "All public subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "private_subnets" {
  type = map(list(object({
    cidr = string
    name = optional(string, "")
  })))

  description = "Map of availability zone to private subnet definition"

  nullable = false

  validation {
    condition     = length(var.private_subnets) >= 2
    error_message = "At least 2 private subnets are required (one per availability zone)."
  }

  validation {
    condition = alltrue([
      for subs in values(var.private_subnets) : length(subs) >= 1
    ])
    error_message = "Each availability zone must define at least one private subnet."
  }

  validation {
    condition = alltrue(flatten([
      for subs in values(var.private_subnets) : [
        for s in subs : can(cidrhost(s.cidr, 0))
      ]
    ]))
    error_message = "All private subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

# ==============================================================================
# NAT GATEWAY CONFIGURATION
# ==============================================================================

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Deploy NAT gateways to allow private subnet internet access (required for most applications)"
  nullable    = false
}

variable "single_nat_gateway" {
  type        = bool
  default     = false
  description = "Use a single NAT gateway for all AZs (cost savings but no high availability). Recommended: false for production, true for dev/staging"
  nullable    = false
}

# ==============================================================================
# SECURITY GROUPS CONFIGURATION
# ==============================================================================

variable "security_groups" {
  type = map(object({
    description = string
  }))
  description = "Map of security groups to create (e.g., {'alb' = {description = 'Security group for Application Load Balancer'}})"
  nullable    = false

  validation {
    condition     = length(var.security_groups) > 0
    error_message = "At least one security group must be defined."
  }
}

variable "ingress_rules" {
  type = map(object({
    sg_key         = string
    cidr_ipv4      = optional(string)
    source_sg_key  = optional(string)
    prefix_list_id = optional(string)
    from_port      = optional(number)
    to_port        = optional(number)
    ip_protocol    = string
    description    = optional(string, "Managed by Terraform")
  }))
  default     = {}
  description = "Map of ingress rules for security groups. Use either cidr_ipv4, source_sg_key, or prefix_list_id"
  nullable    = false

  validation {
    condition = alltrue([
      for rule in var.ingress_rules :
      length(compact([
        rule.cidr_ipv4 != null ? "cidr" : "",
        rule.source_sg_key != null ? "sg" : "",
        rule.prefix_list_id != null ? "pl" : ""
      ])) == 1
    ])
    error_message = "Each ingress rule must specify exactly one of: cidr_ipv4, source_sg_key, or prefix_list_id."
  }

  validation {
    condition = alltrue([
      for rule in var.ingress_rules : contains(
        ["tcp", "udp", "icmp", "icmpv6", "all", "-1"],
        lower(rule.ip_protocol)
      )
    ])
    error_message = "Protocol must be one of: tcp, udp, icmp, icmpv6, all, or -1."
  }
}

variable "egress_rules" {
  type = map(object({
    sg_key      = string
    cidr_ipv4   = string
    from_port   = optional(number)
    to_port     = optional(number)
    ip_protocol = string
    description = optional(string, "Managed by Terraform")
  }))
  default     = {}
  description = "Map of egress rules for security groups"
  nullable    = false

  validation {
    condition = alltrue([
      for rule in var.egress_rules : can(cidrhost(rule.cidr_ipv4, 0))
    ])
    error_message = "All egress rule CIDR blocks must be valid IPv4 CIDR blocks."
  }

  validation {
    condition = alltrue([
      for rule in var.egress_rules : contains(
        ["tcp", "udp", "icmp", "icmpv6", "all", "-1"],
        lower(rule.ip_protocol)
      )
    ])
    error_message = "Protocol must be one of: tcp, udp, icmp, icmpv6, all, or -1."
  }
}
