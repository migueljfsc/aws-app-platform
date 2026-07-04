# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================

variable "deploy_context" {
  type        = string
  description = "The deployment context"
  nullable    = false

  validation {
    condition     = var.deploy_context != ""
    error_message = "Deploy context cannot be empty."
  }
}

variable "service_name" {
  type        = string
  description = "The name of the service (e.g., 'webapp', 'api', 'uploads')"
  nullable    = false

  validation {
    condition     = var.service_name != ""
    error_message = "Service name cannot be empty."
  }
}

# ==============================================================================
# BUCKET BASIC CONFIGURATION
# ==============================================================================

variable "bucket_name" {
  type        = string
  default     = ""
  description = "Custom bucket name. Defaults to '{deploy_context}-s3' if not specified."
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Allow bucket deletion even if it contains objects (use with caution in production)"
  nullable    = false
}

variable "object_ownership" {
  type        = string
  default     = "BucketOwnerEnforced"
  description = "Object ownership setting for the bucket"
  nullable    = false

  validation {
    condition     = contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], var.object_ownership)
    error_message = "Object ownership must be one of: BucketOwnerEnforced, BucketOwnerPreferred, ObjectWriter."
  }
}

# ==============================================================================
# VERSIONING CONFIGURATION
# ==============================================================================

variable "versioning_enabled" {
  type        = bool
  default     = false
  description = "Enable versioning to keep multiple variants of an object in the same bucket"
  nullable    = false
}

variable "versioning_mfa_delete" {
  type        = bool
  default     = false
  description = "Require MFA for deleting object versions (requires versioning_enabled = true)"
  nullable    = false
}

# ==============================================================================
# ENCRYPTION CONFIGURATION
# ==============================================================================

variable "enable_encryption" {
  type        = bool
  default     = true
  description = "Enable server-side encryption for the bucket"
  nullable    = false
}

variable "kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key ID/ARN for encryption (leave empty to use SSE-S3 with AWS-managed keys)"
}

variable "bucket_key_enabled" {
  type        = bool
  default     = true
  description = "Enable S3 Bucket Key to reduce KMS request costs (only applies when using KMS encryption)"
  nullable    = false
}

# ==============================================================================
# PUBLIC ACCESS CONFIGURATION
# ==============================================================================

variable "public_access_block" {
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
  description = "Public access block configuration (recommended: all true for security)"
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
  description = "Lifecycle rules to automatically transition or expire objects (e.g., move to Glacier after 30 days)"
  nullable    = false
}

variable "intelligent_tiering_configurations" {
  type = map(object({
    status = string
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
    tierings = list(object({
      access_tier = string
      days        = number
    }))
  }))
  default     = {}
  description = "Intelligent tiering configurations to automatically optimize storage costs based on access patterns"
  nullable    = false
}

# ==============================================================================
# LOGGING CONFIGURATION
# ==============================================================================

variable "enable_logging" {
  type        = bool
  default     = false
  description = "Enable S3 access logging to track requests made to the bucket"
  nullable    = false
}

variable "logging_target_bucket" {
  type        = string
  default     = ""
  description = "Target bucket name for access logs (required if enable_logging is true)"
}

variable "logging_target_prefix" {
  type        = string
  default     = ""
  description = "Prefix for log objects in the target bucket (e.g., 'logs/mybucket/')"
}

# ==============================================================================
# CORS CONFIGURATION
# ==============================================================================

variable "cors_rules" {
  type = list(object({
    allowed_headers = optional(list(string), [])
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, 3000)
  }))
  default     = []
  description = "CORS rules for cross-origin resource sharing (e.g., for web applications accessing S3 directly)"
  nullable    = false
}

# ==============================================================================
# WEBSITE HOSTING CONFIGURATION
# ==============================================================================

variable "website_configuration" {
  type = object({
    index_document = string
    error_document = optional(string)
    routing_rules  = optional(string)
  })
  default     = null
  description = "Static website hosting configuration (e.g., {index_document = \"index.html\", error_document = \"error.html\"})"
}

# ==============================================================================
# REPLICATION CONFIGURATION
# ==============================================================================

variable "replication_configuration" {
  type = object({
    role_arn = string
    rules = list(object({
      id       = string
      status   = string
      priority = optional(number)
      destination = object({
        bucket             = string
        storage_class      = optional(string)
        replica_kms_key_id = optional(string)
        account_id         = optional(string)
      })
      source_selection_criteria = optional(object({
        sse_kms_encrypted_objects_status = string
      }))
      filter = optional(object({
        prefix = optional(string)
      }))
    }))
  })
  default     = null
  description = "Cross-region or same-region replication configuration for disaster recovery or compliance"
}

# ==============================================================================
# OBJECT LOCK CONFIGURATION
# ==============================================================================

variable "object_lock_enabled" {
  type        = bool
  default     = false
  description = "Enable object lock to prevent object deletion (WORM - Write Once Read Many). WARNING: Can only be enabled at bucket creation"
  nullable    = false
}

variable "object_lock_configuration" {
  type = object({
    mode  = string
    days  = optional(number)
    years = optional(number)
  })
  default     = null
  description = "Object lock retention configuration (mode: GOVERNANCE or COMPLIANCE). Requires object_lock_enabled = true"

  validation {
    condition = (
      var.object_lock_configuration == null ||
      contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock_configuration.mode)
    )
    error_message = "Object lock mode must be either GOVERNANCE or COMPLIANCE."
  }
}

# ==============================================================================
# IAM USER CONFIGURATION
# ==============================================================================

variable "create_iam_user" {
  type        = bool
  default     = false
  description = "Create an IAM user with programmatic access to this bucket (useful for CI/CD or applications)"
  nullable    = false
}

variable "iam_user_name" {
  type        = string
  default     = ""
  description = "Name for the IAM user (defaults to '{service_name}-s3-user' if not specified)"
}

variable "iam_user_permissions" {
  type        = list(string)
  default     = ["read", "write", "delete", "list"]
  description = "Permissions to grant the IAM user (valid values: read, write, delete, list)"
  nullable    = false

  validation {
    condition = alltrue([
      for perm in var.iam_user_permissions : contains(["read", "write", "delete", "list"], perm)
    ])
    error_message = "IAM user permissions must be one or more of: read, write, delete, list."
  }
}

# ==============================================================================
# CLOUDFRONT INTEGRATION
# ==============================================================================

variable "create_cloudfront_oai" {
  type        = bool
  default     = false
  description = "Create CloudFront Origin Access Identity to allow CloudFront to access private bucket content"
  nullable    = false
}

variable "cloudfront_oai_comment" {
  type        = string
  default     = ""
  description = "Comment for the CloudFront OAI (defaults to 'OAI for {service_name}' if not specified)"
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
  description = "List of AWS service principals to grant bucket access via bucket policy (e.g., logdelivery.elasticloadbalancing.amazonaws.com). Use source_arn to restrict to a specific resource."
  nullable    = false
}

# ==============================================================================
# EVENT NOTIFICATIONS
# ==============================================================================

variable "enable_event_notifications" {
  type        = bool
  default     = false
  description = "Enable S3 event notifications to trigger Lambda, SQS, or SNS on object events"
  nullable    = false
}

variable "lambda_notifications" {
  type = map(object({
    lambda_function_arn = string
    events              = list(string)
    filter_prefix       = optional(string)
    filter_suffix       = optional(string)
  }))
  default     = {}
  description = "Lambda function notifications for S3 events (e.g., s3:ObjectCreated:*, s3:ObjectRemoved:*)"
  nullable    = false
}

variable "sqs_notifications" {
  type = map(object({
    queue_arn     = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
  }))
  default     = {}
  description = "SQS queue notifications for S3 events"
  nullable    = false
}

variable "sns_notifications" {
  type = map(object({
    topic_arn     = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
  }))
  default     = {}
  description = "SNS topic notifications for S3 events"
  nullable    = false
}
