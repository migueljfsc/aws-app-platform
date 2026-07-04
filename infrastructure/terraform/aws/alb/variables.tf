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

# ==============================================================================
# ALB BASIC CONFIGURATION
# ==============================================================================

variable "vpc_name" {
  type        = string
  default     = ""
  description = "(Optional) VPC name, defaults to context VPC"
}

variable "internal" {
  type        = bool
  default     = true
  description = "Create an internal ALB (accessible only from within VPC) instead of internet-facing"
  nullable    = false
}

variable "enable_deletion_protection" {
  type        = bool
  default     = false
  description = "Prevent accidental deletion of the ALB (recommended for production)"
  nullable    = false
}

variable "idle_timeout" {
  type        = number
  default     = 60
  description = "Time in seconds that connections can remain idle before being closed (1-4000)"
  nullable    = false

  validation {
    condition     = var.idle_timeout >= 1 && var.idle_timeout <= 4000
    error_message = "Idle timeout must be between 1 and 4000 seconds."
  }
}

# ==============================================================================
# PROTOCOL & PERFORMANCE SETTINGS
# ==============================================================================

variable "enable_http2" {
  type        = bool
  default     = true
  description = "Enable HTTP/2 protocol support for better performance"
  nullable    = false
}

variable "enable_cross_zone_load_balancing" {
  type        = bool
  default     = true
  description = "Distribute traffic evenly across all targets in all enabled AZs"
  nullable    = false
}

variable "drop_invalid_header_fields" {
  type        = bool
  default     = true
  description = "Drop HTTP headers with invalid characters (security best practice)"
  nullable    = false
}

# ==============================================================================
# DOMAIN & ROUTE53
# ==============================================================================
variable "hosts" {
  type = list(object({
    zone_name = string
    host      = optional(string, "")
  }))

  default     = []
  description = "Hosts with their zone names"
  nullable    = false
}

# ==============================================================================
# WAF CONFIGURATION
# ==============================================================================

variable "enable_waf_fail_open" {
  type        = bool
  default     = false
  description = "Allow requests through if WAF is unavailable (use with caution)"
  nullable    = false
}

# ==============================================================================
# ACCESS LOGGING
# ==============================================================================

variable "access_logs_enabled" {
  type        = bool
  default     = false
  description = "Enable access logs to S3 for request tracking and debugging"
  nullable    = false
}

variable "access_logs_prefix" {
  type        = string
  default     = ""
  description = "Prefix for log objects in S3 bucket (e.g., 'alb/production/')"
}

# ==============================================================================
# CLOUDWATCH ALARMS
# ==============================================================================

variable "enable_cloudwatch_alarms" {
  type        = bool
  default     = false
  description = "Create CloudWatch metric alarms for ALB monitoring (5xx, latency, unhealthy hosts)"
  nullable    = false
}

variable "cloudwatch_5xx_threshold" {
  type        = number
  default     = 10
  description = "Threshold for ALB 5XX error count alarm"
  nullable    = false
}

variable "cloudwatch_target_5xx_threshold" {
  type        = number
  default     = 10
  description = "Threshold for target 5XX error count alarm"
  nullable    = false
}

variable "cloudwatch_latency_threshold" {
  type        = number
  default     = 1.0
  description = "Threshold for target response time alarm (seconds)"
  nullable    = false
}

variable "cloudwatch_unhealthy_hosts_threshold" {
  type        = number
  default     = 1
  description = "Threshold for unhealthy host count alarm"
  nullable    = false
}

variable "cloudwatch_alarm_evaluation_periods" {
  type        = number
  default     = 3
  description = "Number of consecutive periods the metric must breach before alarming"
  nullable    = false

  validation {
    condition     = var.cloudwatch_alarm_evaluation_periods >= 1
    error_message = "Evaluation periods must be at least 1."
  }
}

variable "cloudwatch_alarm_period" {
  type        = number
  default     = 300
  description = "Period in seconds for metric evaluation (e.g., 300 = 5 minutes)"
  nullable    = false

  validation {
    condition     = contains([10, 30, 60, 120, 180, 300, 600, 900, 1800, 3600], var.cloudwatch_alarm_period)
    error_message = "Alarm period must be one of: 10, 30, 60, 120, 180, 300, 600, 900, 1800, 3600."
  }
}

# ==============================================================================
# TARGET GROUPS
# ==============================================================================

variable "target_groups" {
  type = map(object({
    port                          = number
    protocol                      = string
    target_type                   = string
    deregistration_delay          = optional(number, 30)
    slow_start                    = optional(number, 0)
    load_balancing_algorithm_type = optional(string, "round_robin")
    stickiness = optional(object({
      enabled         = bool
      type            = string
      cookie_duration = optional(number, 86400)
      cookie_name     = optional(string, "")
    }), null)
    health_check = object({
      enabled             = optional(bool, true)
      healthy_threshold   = optional(number, 2)
      unhealthy_threshold = optional(number, 3)
      timeout             = optional(number, 5)
      interval            = optional(number, 30)
      path                = optional(string, "/")
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "HTTP")
      matcher             = optional(string, "200")
    })
  }))
  default     = {}
  description = "Map of target groups to route traffic to backend services (ECS tasks, EC2 instances, Lambda functions, etc.)"
  nullable    = false

  validation {
    condition = alltrue([
      for tg in var.target_groups : contains(["HTTP", "HTTPS", "TCP", "TLS", "UDP", "TCP_UDP", "GENEVE"], tg.protocol)
    ])
    error_message = "Target group protocol must be one of: HTTP, HTTPS, TCP, TLS, UDP, TCP_UDP, GENEVE."
  }

  validation {
    condition = alltrue([
      for tg in var.target_groups : contains(["instance", "ip", "lambda", "alb"], tg.target_type)
    ])
    error_message = "Target type must be one of: instance, ip, lambda, alb."
  }

  validation {
    condition = alltrue([
      for tg in var.target_groups : contains(["round_robin", "least_outstanding_requests"], tg.load_balancing_algorithm_type)
    ])
    error_message = "Load balancing algorithm must be either round_robin or least_outstanding_requests."
  }

  validation {
    condition = alltrue([
      for tg in var.target_groups : tg.deregistration_delay >= 0 && tg.deregistration_delay <= 3600
    ])
    error_message = "Deregistration delay must be between 0 and 3600 seconds."
  }

  validation {
    condition = alltrue([
      for tg in var.target_groups : tg.slow_start >= 0 && tg.slow_start <= 900
    ])
    error_message = "Slow start duration must be between 0 and 900 seconds."
  }
}

# ==============================================================================
# HTTP LISTENERS
# ==============================================================================

variable "http_listeners" {
  type = map(object({
    port     = number
    protocol = string
    action = object({
      type             = string
      target_group_key = optional(string, "")
      redirect = optional(object({
        port        = string
        protocol    = string
        status_code = string
      }), null)
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string, "")
        status_code  = string
      }), null)
    })
  }))
  default     = {}
  description = "Map of HTTP listeners (typically used to redirect to HTTPS)"
  nullable    = false

  validation {
    condition = alltrue([
      for listener in var.http_listeners : listener.port >= 1 && listener.port <= 65535
    ])
    error_message = "Listener port must be between 1 and 65535."
  }

  validation {
    condition = alltrue([
      for listener in var.http_listeners : listener.protocol == "HTTP"
    ])
    error_message = "HTTP listener protocol must be HTTP."
  }

  validation {
    condition = alltrue([
      for listener in var.http_listeners : contains(["forward", "redirect", "fixed-response"], listener.action.type)
    ])
    error_message = "HTTP listener action type must be one of: forward, redirect, fixed-response."
  }
}

# ==============================================================================
# HTTPS LISTENERS
# ==============================================================================

variable "https_listeners" {
  type = map(object({
    port                = number
    protocol            = string
    certificate_domains = optional(list(string), [])
    ssl_policy          = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
    action = object({
      type             = string
      target_group_key = optional(string, "")
      redirect = optional(object({
        port        = string
        protocol    = string
        status_code = string
      }), null)
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string, "")
        status_code  = string
      }), null)
    })
  }))
  default     = {}
  description = "Map of HTTPS listeners with SSL/TLS certificates"
  nullable    = false

  validation {
    condition = alltrue([
      for listener in var.https_listeners : listener.port >= 1 && listener.port <= 65535
    ])
    error_message = "Listener port must be between 1 and 65535."
  }

  validation {
    condition = alltrue([
      for listener in var.https_listeners : listener.protocol == "HTTPS"
    ])
    error_message = "HTTPS listener protocol must be HTTPS."
  }

  validation {
    condition = alltrue([
      for listener in var.https_listeners : contains(["forward", "redirect", "fixed-response"], listener.action.type)
    ])
    error_message = "HTTPS listener action type must be one of: forward, redirect, fixed-response."
  }
}

# ==============================================================================
# LISTENER RULES
# ==============================================================================

variable "listener_rules" {
  type = map(object({
    listener_key     = string
    priority         = number
    target_group_key = string
    conditions = list(object({
      path_pattern = optional(list(string), [])
      host_header  = optional(list(string), [])
      http_header = optional(object({
        name   = string
        values = list(string)
      }), null)
      query_string = optional(list(object({
        key   = optional(string, "")
        value = string
      })), [])
      source_ip = optional(list(string), [])
    }))
  }))
  default     = {}
  description = "Map of listener rules for advanced routing (path-based, host-based, header-based, etc.)"
  nullable    = false

  validation {
    condition = alltrue([
      for rule in var.listener_rules : rule.priority >= 1 && rule.priority <= 50000
    ])
    error_message = "Listener rule priority must be between 1 and 50000."
  }
}
