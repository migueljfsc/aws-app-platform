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


# ==============================================================================
# GITHUB VARIABLES
# ==============================================================================
variable "repository_name" {
  type        = string
  default     = ""
  description = "The name of the GitHub repository."
}

variable "repository_branch" {
  type        = string
  default     = "main"
  description = "The branch of the GitHub repository to apply the ruleset to."
}

variable "required_checks" {
  type = list(object({
    context        = string
    integration_id = optional(number)
  }))

  default = [
    {
      context        = "Pre-commit checks"
      integration_id = 15368 # Github Actions - curl https://api.github.com/apps/github-actions
    }
  ]
  description = "Status check required to merge the PR."
}

variable "bypass_actors" {
  type = list(object({
    actor_id    = number
    actor_type  = string
    bypass_mode = optional(string, "always")
  }))

  default = [
    {
      actor_id   = 0 # replace with your GitHub Team ID
      actor_type = "Team"
    },
    {
      actor_id   = 5 # Repo Admins
      actor_type = "RepositoryRole"
    }
  ]
}
