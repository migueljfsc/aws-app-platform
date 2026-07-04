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

variable "alb_name" {
  type        = string
  description = "Name of an existing Application Load Balancer to route traffic through"
  nullable    = false
}

# ==============================================================================
# OPTIONAL VARIABLES
# ==============================================================================
variable "container_image_tag" {
  type        = string
  default     = ""
  description = "Docker image tag for the container"
  nullable    = false
}

variable "create_ecr_repo" {
  type        = bool
  default     = true
  description = "Whether to create ECR repositories"
  nullable    = false
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "Desired number of ECS tasks to run"
  nullable    = false

  validation {
    condition     = var.desired_count >= 0
    error_message = "Desired count must be 0 or greater."
  }
}

variable "cloudwatch_log_retention_days" {
  type        = number
  default     = 30
  description = "Number of days to retain CloudWatch logs"
  nullable    = false

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.cloudwatch_log_retention_days)
    error_message = "Log retention must be a valid CloudWatch retention value (0 = never expire)."
  }
}
