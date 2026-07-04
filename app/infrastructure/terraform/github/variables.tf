###################### MODULE VARIABLES ######################

# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================
variable "service_name" {
  type        = string
  description = "The name of the service"
  nullable    = false

  validation {
    condition     = var.service_name != ""
    error_message = "Service name cannot be empty."
  }
}

variable "github_organization" {
  type        = string
  description = "The name of the GitHub organization."

  validation {
    condition     = var.github_organization != ""
    error_message = "GitHub organization cannot be empty."
  }
}
