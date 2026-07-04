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
# BUCKET CONFIGURATION
# ==============================================================================

variable "bucket_name" {
  type        = string
  default     = ""
  description = "Custom bucket name. Defaults to '{service_name}-{deploy_context}-s3' if not specified."
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Allow bucket deletion even if it contains objects (use with caution in production)"
  nullable    = false
}

variable "versioning_enabled" {
  type        = bool
  default     = false
  description = "Enable versioning to keep multiple variants of an object in the same bucket"
  nullable    = false
}

variable "enable_encryption" {
  type        = bool
  default     = true
  description = "Enable server-side encryption for the bucket"
  nullable    = false
}

# ==============================================================================
# LIFECYCLE RULES
# ==============================================================================

variable "lifecycle_rules" {
  type = map(object({
    enabled = bool
    prefix  = optional(string, "")
    tags    = optional(map(string), {})
    expiration = optional(object({
      days                         = optional(number)
      expired_object_delete_marker = optional(bool)
    }))
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }))
    transition = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    noncurrent_version_transition = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })), [])
    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = number
    }))
  }))
  default     = {}
  description = "Lifecycle rules to automatically transition or expire objects"
  nullable    = false
}

# ==============================================================================
# IAM ACCESS PERMISSIONS
# ==============================================================================

variable "allowed_iam_arns" {
  type        = list(string)
  default     = []
  description = "List of IAM role/user ARNs to grant bucket access (e.g., ECS task roles, Lambda execution roles)"
  nullable    = false
}

variable "allowed_iam_permissions" {
  type        = list(string)
  default     = ["read"]
  description = "Permissions to grant to allowed IAM ARNs (valid values: read, write, delete, list)"
  nullable    = false

  validation {
    condition = alltrue([
      for perm in var.allowed_iam_permissions : contains(["read", "write", "delete", "list"], perm)
    ])
    error_message = "Allowed IAM permissions must be one or more of: read, write, delete, list."
  }
}

# ==============================================================================
# SERVICE PRINCIPAL ACCESS
# ==============================================================================

variable "allowed_service_principals" {
  type = list(object({
    identifier         = string
    actions            = list(string)
    include_bucket_arn = optional(bool, false)
    source_arn         = optional(string, "")
  }))
  default     = []
  description = "List of AWS service principals to grant bucket access via bucket policy"
  nullable    = false
}
