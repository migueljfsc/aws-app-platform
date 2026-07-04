###################### MODULE VARIABLES ######################

# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================
variable "service_name" {
  type        = string
  description = "The name of the service (e.g., 'webapp', 'api', 'worker'). Used as the ECR repository name"
  nullable    = false

  validation {
    condition     = var.service_name != ""
    error_message = "Service name cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-_]*[a-z0-9])?$", var.service_name))
    error_message = "Service name must start and end with lowercase alphanumeric characters, and can contain hyphens and underscores."
  }
}

# ==============================================================================
# REPOSITORY CONFIGURATION
# ==============================================================================

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "Whether image tags can be overwritten. IMMUTABLE prevents tag overwrites (recommended for production)"
  nullable    = false

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "repository_force_delete" {
  type        = bool
  default     = false
  description = "Allow repository deletion even if it contains images (use with caution in production)"
  nullable    = false
}

# ==============================================================================
# SECURITY & SCANNING
# ==============================================================================

variable "scan_on_push" {
  type        = bool
  default     = true
  description = "Enable automatic image scanning for vulnerabilities when images are pushed"
  nullable    = false
}

variable "encryption_type" {
  type        = string
  default     = "AES256"
  description = "Encryption type for images at rest. Use AES256 for AWS-managed keys or KMS for customer-managed keys"
  nullable    = false

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Encryption type must be either AES256 or KMS."
  }
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "ARN of KMS key for encryption (required if encryption_type is KMS, ignored otherwise)"

  validation {
    condition = (
      var.kms_key_arn == "" ||
      can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-f0-9-]+$", var.kms_key_arn))
    )
    error_message = "KMS key ARN must be a valid ARN format or empty."
  }
}

# ==============================================================================
# LIFECYCLE POLICIES
# ==============================================================================

variable "enable_default_lifecycle_policy" {
  type        = bool
  default     = true
  description = "Enable default lifecycle policy to automatically expire old images (keeps last 30 images)"
  nullable    = false
}

variable "lifecycle_policy" {
  type        = any
  default     = null
  description = "Custom lifecycle policy configuration to override the default policy. Set to null to use default or disable lifecycle policies"

  validation {
    condition = (
      var.lifecycle_policy == null ||
      (
        can(var.lifecycle_policy.rules) &&
        length(var.lifecycle_policy.rules) > 0 &&
        alltrue([
          for r in var.lifecycle_policy.rules : (
            can(r.rulePriority) &&
            can(r.description) &&
            can(r.selection) &&
            can(r.selection.tagStatus) &&
            (can(r.selection.tagPrefixList) || !contains(keys(r.selection), "tagPrefixList")) &&
            can(r.selection.countType) &&
            (can(r.selection.countUnit) || !contains(keys(r.selection), "countUnit")) &&
            can(r.selection.countNumber) &&
            can(r.action) &&
            can(r.action.type)
          )
        ])
      )
    )
    error_message = "Lifecycle policy must be null or an object with correctly structured rules (rulePriority, description, selection, action)."
  }
}

# ==============================================================================
# ACCESS PERMISSIONS
# ==============================================================================

variable "allowed_principals" {
  type        = list(string)
  default     = []
  description = "List of AWS principal ARNs (IAM roles/users) allowed to pull images from this repository (e.g., ['arn:aws:iam::123456789012:role/ecs-task-role'])"
  nullable    = false

  validation {
    condition = alltrue([
      for arn in var.allowed_principals : can(regex("^arn:aws:iam::[0-9]{12}:(role|user)/", arn))
    ])
    error_message = "All allowed principals must be valid IAM role or user ARNs."
  }
}

variable "allowed_account_ids" {
  type        = list(string)
  default     = []
  description = "List of AWS account IDs allowed to pull images from this repository (for cross-account access)"
  nullable    = false

  validation {
    condition = alltrue([
      for account_id in var.allowed_account_ids : can(regex("^[0-9]{12}$", account_id))
    ])
    error_message = "All account IDs must be 12-digit numbers."
  }
}

# ==============================================================================
# REPLICATION CONFIGURATION
# ==============================================================================

variable "enable_cross_account_replication" {
  type        = bool
  default     = false
  description = "Enable cross-region or cross-account replication for disaster recovery or multi-region deployments"
  nullable    = false
}

variable "replication_configuration" {
  type = object({
    rules = list(object({
      destinations = list(object({
        region      = string
        registry_id = string
      }))
      repository_filters = optional(list(object({
        filter      = string
        filter_type = string
      })))
    }))
  })
  default     = null
  description = "Replication configuration for copying images to other regions/accounts. Required if enable_cross_account_replication is true"

  validation {
    condition = (
      var.replication_configuration == null ||
      (
        can(var.replication_configuration.rules) &&
        length(var.replication_configuration.rules) > 0 &&
        alltrue([
          for rule in var.replication_configuration.rules : (
            length(rule.destinations) > 0 &&
            alltrue([
              for dest in rule.destinations : (
                can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", dest.region)) &&
                can(regex("^[0-9]{12}$", dest.registry_id))
              )
            ])
          )
        ])
      )
    )
    error_message = "Replication configuration must have valid rules with at least one destination containing a valid AWS region and 12-digit registry ID."
  }
}
