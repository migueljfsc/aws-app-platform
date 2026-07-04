###################### MODULE VARIABLES ######################

# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================
variable "service_name" {
  type        = string
  description = "The name of the service (e.g., 'api', 'backend', 'gateway')"
  nullable    = false

  validation {
    condition     = var.service_name != ""
    error_message = "Service name cannot be empty."
  }
}

variable "environment" {
  type        = string
  description = "The environment of the deployment (e.g. 'dev', 'stg')"
  nullable    = false
  validation {
    condition     = var.environment != ""
    error_message = "Module variable environment cannot be empty."
  }
}

# ==============================================================================
# API CONFIGURATION
# ==============================================================================

variable "api_type" {
  type        = string
  default     = "REST"
  description = "Type of API Gateway (REST or HTTP)"
  nullable    = false

  validation {
    condition     = contains(["REST", "HTTP"], var.api_type)
    error_message = "API type must be either REST or HTTP."
  }
}

variable "protocol_type" {
  type        = string
  default     = "HTTP"
  description = "Protocol type for HTTP API (HTTP or WEBSOCKET)"
  nullable    = false

  validation {
    condition     = contains(["HTTP", "WEBSOCKET"], var.protocol_type)
    error_message = "Protocol type must be either HTTP or WEBSOCKET."
  }
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of the API Gateway"
}

variable "endpoint_type" {
  type        = string
  default     = "REGIONAL"
  description = "Endpoint type (EDGE, REGIONAL, or PRIVATE)"
  nullable    = false

  validation {
    condition     = contains(["EDGE", "REGIONAL", "PRIVATE"], var.endpoint_type)
    error_message = "Endpoint type must be EDGE, REGIONAL, or PRIVATE."
  }
}

variable "disable_execute_api_endpoint" {
  type        = bool
  default     = false
  description = "Disable the default execute-api endpoint (use with custom domains)"
  nullable    = false
}

# ==============================================================================
# AUTHORIZERS
# ==============================================================================
variable "cognito_authorizers" {
  type = map(object({
    issuer           = string
    audience         = optional(list(string), [])
    identity_sources = optional(list(string), ["$request.header.Authorization"])
  }))
  default     = {}
  description = "Cognito JWT authorizers for HTTP API"
  nullable    = false

  validation {
    condition = alltrue([
      for v in var.cognito_authorizers :
      length(v.audience) > 0
    ])
    error_message = "Audience must not be empty."
  }

  validation {
    condition = alltrue([
      for v in var.cognito_authorizers :
      v.issuer != ""
    ])
    error_message = "Issuer must not be empty."
  }
}

# ==============================================================================
# CORS CONFIGURATION
# ==============================================================================

variable "cors_configuration" {
  type = object({
    allow_origins     = optional(list(string), ["*"])
    allow_methods     = optional(list(string), ["GET", "POST", "PUT", "DELETE", "OPTIONS"])
    allow_headers     = optional(list(string), ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"])
    expose_headers    = optional(list(string), [])
    max_age           = optional(number, 300)
    allow_credentials = optional(bool, false)
  })
  default     = null
  description = "CORS configuration for the API"
}

# ==============================================================================
# DEPLOYMENT & STAGES
# ==============================================================================

variable "stage_name" {
  type        = string
  default     = "dev"
  description = "Name of the deployment stage"
  nullable    = false
}

variable "stage_description" {
  type        = string
  default     = ""
  description = "Description of the deployment stage"
}

variable "stage_variables" {
  type        = map(string)
  default     = {}
  description = "Stage variables"
  nullable    = false
}

variable "auto_deploy" {
  type        = bool
  default     = true
  description = "Automatically deploy changes (HTTP API only)"
  nullable    = false
}

variable "throttle_burst_limit" {
  type        = number
  default     = 5000
  description = "Throttle burst limit"
  nullable    = false

  validation {
    condition     = var.throttle_burst_limit >= 0
    error_message = "Throttle burst limit must be >= 0."
  }
}

variable "throttle_rate_limit" {
  type        = number
  default     = 10000
  description = "Throttle rate limit (requests per second)"
  nullable    = false

  validation {
    condition     = var.throttle_rate_limit >= 0
    error_message = "Throttle rate limit must be >= 0."
  }
}

# ==============================================================================
# LOGGING & MONITORING
# ==============================================================================

variable "enable_access_logging" {
  type        = bool
  default     = true
  description = "Enable access logging"
  nullable    = false
}

variable "access_log_format" {
  type        = string
  default     = ""
  description = "Access log format (JSON format recommended). Leave empty for default."
}

variable "cloudwatch_log_retention_days" {
  type        = number
  default     = 3
  description = "CloudWatch log retention in days"
  nullable    = false

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.cloudwatch_log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch Logs retention period."
  }
}

variable "enable_execution_logging" {
  type        = bool
  default     = false
  description = "Enable execution logging (detailed request/response logging)"
  nullable    = false
}

variable "logging_level" {
  type        = string
  default     = "INFO"
  description = "Logging level for execution logs (INFO or ERROR)"
  nullable    = false

  validation {
    condition     = contains(["INFO", "ERROR", "OFF"], var.logging_level)
    error_message = "Logging level must be INFO, ERROR, or OFF."
  }
}

variable "enable_metrics" {
  type        = bool
  default     = true
  description = "Enable detailed CloudWatch metrics"
  nullable    = false
}

variable "enable_tracing" {
  type        = bool
  default     = false
  description = "Enable X-Ray tracing"
  nullable    = false
}

# ==============================================================================
# API KEYS & USAGE PLANS
# ==============================================================================

variable "api_keys" {
  type = map(object({
    description = optional(string, "")
    enabled     = optional(bool, true)
  }))
  default     = {}
  description = "Map of API keys to create"
  nullable    = false
}

variable "usage_plans" {
  type = map(object({
    description = optional(string, "")
    quota = optional(object({
      limit  = number
      offset = optional(number, 0)
      period = string # DAY, WEEK, MONTH
    }))
    throttle = optional(object({
      burst_limit = number
      rate_limit  = number
    }))
    api_key_keys = optional(list(string), [])
  }))
  default     = {}
  description = "Map of usage plans"
  nullable    = false
}

# ==============================================================================
# CUSTOM DOMAIN
# ==============================================================================

variable "create_custom_domain" {
  type        = bool
  default     = false
  description = "Create a custom domain for the API"
  nullable    = false
}

variable "domain_name" {
  type        = string
  default     = ""
  description = "Custom domain name"
}

variable "certificate_domain_name" {
  type        = string
  default     = ""
  description = "ACM certificate domain name"
}

variable "certificate_arn" {
  type        = string
  default     = ""
  description = "ACM certificate ARN for custom domain (must be in us-east-1 for EDGE)"

  validation {
    condition     = var.certificate_arn == "" || can(regex("^arn:aws:acm:", var.certificate_arn))
    error_message = "Certificate ARN must be a valid ACM certificate ARN."
  }
}

variable "base_path" {
  type        = string
  default     = ""
  description = "Base path mapping for custom domain (e.g., 'v1', 'api')"
}

variable "security_policy" {
  type        = string
  default     = "TLS_1_2"
  description = "Security policy for custom domain"
  nullable    = false

  validation {
    condition     = contains(["TLS_1_0", "TLS_1_2"], var.security_policy)
    error_message = "Security policy must be TLS_1_0 or TLS_1_2."
  }
}

# ==============================================================================
# ROUTE53 INTEGRATION
# ==============================================================================

variable "create_route53_record" {
  type        = bool
  default     = false
  description = "Create Route53 record for custom domain"
  nullable    = false
}

variable "route53_zone_id" {
  type        = string
  default     = ""
  description = "Route53 hosted zone ID"
}

variable "route53_zone_name" {
  type        = string
  default     = ""
  description = "Route53 hosted zone name (alternative to zone_id)"
}

# ==============================================================================
# WAF INTEGRATION
# ==============================================================================
variable "web_acl_name" {
  type        = string
  default     = ""
  description = "Name of AWS WAF Web ACL to associate with the distribution (for DDoS protection and security rules)"
}

variable "attach_web_acl" {
  type        = bool
  default     = true
  description = "Whether to attach the WAF Web ACL to the API Gateway stage"
  nullable    = false
}


# ==============================================================================
# REQUEST VALIDATION
# ==============================================================================

variable "create_request_validator" {
  type        = bool
  default     = false
  description = "Create a request validator"
  nullable    = false
}

variable "validate_request_body" {
  type        = bool
  default     = true
  description = "Validate request body"
  nullable    = false
}

variable "validate_request_parameters" {
  type        = bool
  default     = true
  description = "Validate request parameters"
  nullable    = false
}

# ==============================================================================
# VPC LINK (for private integrations)
# ==============================================================================

variable "create_vpc_link" {
  type        = bool
  default     = false
  description = "Create VPC Link for private integrations"
  nullable    = false
}

variable "vpc_link_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnet IDs for VPC Link"
  nullable    = false
}

variable "vpc_link_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security group IDs for VPC Link"
  nullable    = false
}
