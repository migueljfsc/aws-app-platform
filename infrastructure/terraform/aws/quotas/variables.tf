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
# QUOTA INCREASES VARIABLES
# ==============================================================================
variable "quota_increases" {
  type = map(object({
    service_code  = string
    quota_name    = string
    desired_value = number
  }))
  default     = {}
  description = "Map of service quota increase requests using quota names (will be looked up dynamically)"
  nullable    = false

  validation {
    condition = alltrue([
      for quota in var.quota_increases : quota.desired_value > 0
    ])
    error_message = "Desired value must be greater than 0."
  }
}
