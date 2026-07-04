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
# OPTIONAL VARIABLES
# ==============================================================================
variable "create_ecr_repo" {
  type        = bool
  default     = true
  description = "Whether to create ECR repositories"
  nullable    = false
}

variable "container_image_tag" {
  type        = string
  default     = ""
  description = "Docker image tag for the container"
  nullable    = false
}

variable "api_gateway_name" {
  type        = string
  default     = "app-api"
  description = "The name of the API Gateway"
  nullable    = false

  validation {
    condition     = var.api_gateway_name != ""
    error_message = "API Gateway name cannot be empty."
  }
}

variable "api_gateway_type" {
  type        = string
  default     = "HTTP"
  description = "The type of the API Gateway"
  nullable    = false

  validation {
    condition     = var.api_gateway_type == "HTTP" || var.api_gateway_type == "REST"
    error_message = "API Gateway type must be HTTP or REST."
  }
}

variable "api_gateway_authorizer_id" {
  type        = string
  default     = ""
  description = "The id of the API Gateway Authorizer"
  nullable    = false

  validation {
    condition     = var.api_gateway_authorizer_id != ""
    error_message = "API Gateway authorizer id cannot be empty."
  }
}

variable "api_gateway_authorization_type" {
  type        = string
  default     = "JWT"
  description = "The type of authorization for the API Gateway"
  nullable    = false

  validation {
    condition     = var.api_gateway_authorization_type != ""
    error_message = "API Gateway authorization type cannot be empty."
  }
}

variable "route_path" {
  type        = string
  description = "The path of the API Gateway route"
  nullable    = false
}
