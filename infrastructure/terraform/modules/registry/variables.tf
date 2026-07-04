variable "deployed_by" {
  type        = string
  default     = "Github Actions"
  description = "How the infrastructure was deployed"
  nullable    = false
}

variable "repository" {
  type        = string
  description = "The name of the repository that contains the infrastructure code."
  nullable    = false
  validation {
    condition     = var.repository != ""
    error_message = "Module variable repository cannot be empty."
  }
}

variable "team" {
  type        = string
  description = "Team that owns this infrastructure."
  default     = "devops"
  nullable    = false
  validation {
    condition     = var.team != ""
    error_message = "Module variable team cannot be empty."
  }
}

variable "region" {
  type        = string
  description = "The region to deploy to"
  default     = "eu-west-3"
  nullable    = false
  validation {
    condition     = var.region != ""
    error_message = "Module variable region cannot be empty."
  }
}


variable "environment" {
  type        = string
  description = "The environment of the deployment (e.g. 'prod', 'staging')"
  nullable    = false
  validation {
    condition     = var.environment != ""
    error_message = "Module variable environment cannot be empty."
  }
}

variable "service_name" {
  type        = string
  description = "The name of the service being deployed. (e.g. 'my-service')"
  nullable    = false
  validation {
    condition     = var.service_name != ""
    error_message = "Module variable service_name cannot be empty."
  }
}

variable "deploy_context" {
  type        = string
  description = "The context of the deploy"
  default     = ""
  nullable    = false
}

variable "additional_tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. `map(`BusinessUnit`,`XYZ`)"
  nullable    = false
  validation {
    condition     = length([for tag_value in values(var.additional_tags) : tag_value if tag_value == ""]) == 0
    error_message = "Module variable additional_tags may not have empty values."
  }
}
