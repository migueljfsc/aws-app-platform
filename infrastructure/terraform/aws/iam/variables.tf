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
# IAM USERS
# ==============================================================================

variable "users" {
  type = map(object({
    path                 = optional(string, "/")
    force_destroy        = optional(bool, false)
    permissions_boundary = optional(string, "")
    groups               = optional(list(string), [])
    tags                 = optional(map(string), {})
  }))
  default     = {}
  description = "Map of IAM users to create"
  nullable    = false
}

variable "existing_users" {
  type = map(object({
    groups = optional(list(string), [])
  }))
  default     = {}
  description = "Map of existing IAM users to add to groups (users must already exist in AWS)"
  nullable    = false
}

variable "create_user_access_keys" {
  type        = bool
  default     = false
  description = "Create access keys for IAM users (stores in Terraform state - use with caution)"
  nullable    = false
}

variable "user_access_keys" {
  type        = set(string)
  default     = []
  description = "Set of user keys to create access keys for (if create_user_access_keys is true)"
  nullable    = false
}

variable "create_user_login_profiles" {
  type        = bool
  default     = false
  description = "Create console login profiles for IAM users"
  nullable    = false
}

variable "user_login_profiles" {
  type = map(object({
    password_length         = optional(number, 32)
    password_reset_required = optional(bool, true)
  }))
  default     = {}
  description = "Map of user login profile configurations"
  nullable    = false
}

# ==============================================================================
# IAM GROUPS
# ==============================================================================

variable "groups" {
  type = map(object({
    path = optional(string, "/")
  }))
  default     = {}
  description = "Map of IAM groups to create"
  nullable    = false
}

variable "group_policies" {
  type = map(object({
    group_key = string
    policy_statements = list(object({
      sid       = optional(string)
      effect    = string
      actions   = list(string)
      resources = list(string)
      conditions = optional(list(object({
        test     = string
        variable = string
        values   = list(string)
      })), [])
    }))
  }))
  default     = {}
  description = "Map of inline policies to attach to groups"
  nullable    = false
}

variable "group_policy_attachments" {
  type = map(object({
    group_key  = string
    policy_arn = string
  }))
  default     = {}
  description = "Map of managed policy ARNs to attach to groups"
  nullable    = false
}

# ==============================================================================
# IAM ROLES
# ==============================================================================

variable "roles" {
  type = map(object({
    path                  = optional(string, "/")
    description           = optional(string, "")
    max_session_duration  = optional(number, 3600)
    force_detach_policies = optional(bool, false)
    permissions_boundary  = optional(string, "")

    # Trust policy (assume role policy)
    assume_role_policy = optional(object({
      action = optional(string, "")
      principals = list(object({
        type        = string
        identifiers = list(string)
      }))
      conditions = optional(list(object({
        test     = string
        variable = string
        values   = list(string)
      })), [])
    }))

    # Alternative: raw JSON assume role policy
    assume_role_policy_json = optional(string, "")

    tags = optional(map(string), {})
  }))
  default     = {}
  description = "Map of IAM roles to create"
  nullable    = false

  validation {
    condition = alltrue([
      for role in var.roles : role.max_session_duration >= 3600 && role.max_session_duration <= 43200
    ])
    error_message = "Max session duration must be between 3600 (1 hour) and 43200 (12 hours)."
  }
}

variable "role_policies" {
  type = map(object({
    role_key = string
    policy_statements = list(object({
      sid       = optional(string)
      effect    = string
      actions   = list(string)
      resources = list(string)
      conditions = optional(list(object({
        test     = string
        variable = string
        values   = list(string)
      })), [])
    }))
  }))
  default     = {}
  description = "Map of inline policies to attach to roles"
  nullable    = false
}

variable "role_policy_attachments" {
  type = map(object({
    role_key   = string
    policy_arn = string
  }))
  default     = {}
  description = "Map of managed policy ARNs to attach to roles"
  nullable    = false
}

# ==============================================================================
# IAM POLICIES (Customer Managed)
# ==============================================================================

variable "policies" {
  type = map(object({
    path        = optional(string, "/")
    description = optional(string, "")
    policy_statements = list(object({
      sid       = optional(string)
      effect    = string
      actions   = list(string)
      resources = list(string)
      conditions = optional(list(object({
        test     = string
        variable = string
        values   = list(string)
      })), [])
    }))
    tags = optional(map(string), {})
  }))
  default     = {}
  description = "Map of customer-managed IAM policies to create"
  nullable    = false
}

# ==============================================================================
# INSTANCE PROFILES (for EC2)
# ==============================================================================

variable "instance_profiles" {
  type = map(object({
    path     = optional(string, "/")
    role_key = string
  }))
  default     = {}
  description = "Map of instance profiles to create (for EC2 instances)"
  nullable    = false
}

# ==============================================================================
# SERVICE-LINKED ROLES
# ==============================================================================

variable "service_linked_roles" {
  type = map(object({
    aws_service_name = string
    description      = optional(string, "")
    custom_suffix    = optional(string, "")
  }))
  default     = {}
  description = "Map of service-linked roles to create"
  nullable    = false
}

# ==============================================================================
# OIDC PROVIDERS (for GitHub Actions, etc.)
# ==============================================================================

variable "oidc_providers" {
  type = map(object({
    url             = string
    client_id_list  = list(string)
    thumbprint_list = optional(list(string), [])
    tags            = optional(map(string), {})
  }))
  default     = {}
  description = "Map of OIDC identity providers (e.g., for GitHub Actions)"
  nullable    = false
}

# ==============================================================================
# SAML PROVIDERS (for SSO)
# ==============================================================================

variable "saml_providers" {
  type = map(object({
    saml_metadata_document = string
    tags                   = optional(map(string), {})
  }))
  default     = {}
  description = "Map of SAML identity providers (e.g., for SSO)"
  nullable    = false
}
