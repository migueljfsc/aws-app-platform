
###################### MODULE VARIABLES ######################

# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================
variable "deploy_context" {
  type        = string
  description = "The deployment context (e.g., 'production', 'staging', 'development')"
  nullable    = false

  validation {
    condition     = var.deploy_context != ""
    error_message = "Deploy context cannot be empty."
  }
}

variable "service_name" {
  type        = string
  description = "The name of the service (e.g., 'alerts', 'notifications', 'events')"
  nullable    = false

  validation {
    condition     = var.service_name != ""
    error_message = "Service name cannot be empty."
  }
}

# ==============================================================================
# TOPIC CONFIGURATION
# ==============================================================================

variable "display_name" {
  type        = string
  default     = ""
  description = "Display name for the SNS topic (max 100 characters)"

  validation {
    condition     = var.display_name == "" || length(var.display_name) <= 100
    error_message = "Display name must be 100 characters or less."
  }
}

variable "fifo_topic" {
  type        = bool
  default     = false
  description = "Create a FIFO topic (requires .fifo suffix in name)"
  nullable    = false
}

variable "content_based_deduplication" {
  type        = bool
  default     = false
  description = "Enable content-based deduplication for FIFO topics"
  nullable    = false
}

variable "kms_master_key_id" {
  type        = string
  default     = ""
  description = "KMS key ID for server-side encryption (leave empty for no encryption)"
}

variable "signature_version" {
  type        = number
  default     = 1
  description = "Signature version for message signing (1 or 2)"
  nullable    = false

  validation {
    condition     = contains([1, 2], var.signature_version)
    error_message = "Signature version must be 1 or 2."
  }
}

variable "tracing_config" {
  type        = string
  default     = "PassThrough"
  description = "X-Ray tracing configuration (PassThrough or Active)"
  nullable    = false

  validation {
    condition     = contains(["PassThrough", "Active"], var.tracing_config)
    error_message = "Tracing config must be either PassThrough or Active."
  }
}

# ==============================================================================
# DELIVERY POLICY
# ==============================================================================

variable "delivery_policy" {
  type        = string
  default     = ""
  description = "JSON delivery policy for the topic (controls retry behavior)"
}

variable "http_success_feedback_role_arn" {
  type        = string
  default     = ""
  description = "IAM role ARN for HTTP success feedback"
}

variable "http_success_feedback_sample_rate" {
  type        = number
  default     = 100
  description = "Percentage of successful HTTP deliveries to sample (0-100)"
  nullable    = false

  validation {
    condition     = var.http_success_feedback_sample_rate >= 0 && var.http_success_feedback_sample_rate <= 100
    error_message = "Sample rate must be between 0 and 100."
  }
}

variable "http_failure_feedback_role_arn" {
  type        = string
  default     = ""
  description = "IAM role ARN for HTTP failure feedback"
}

variable "lambda_success_feedback_role_arn" {
  type        = string
  default     = ""
  description = "IAM role ARN for Lambda success feedback"
}

variable "lambda_success_feedback_sample_rate" {
  type        = number
  default     = 100
  description = "Percentage of successful Lambda deliveries to sample (0-100)"
  nullable    = false

  validation {
    condition     = var.lambda_success_feedback_sample_rate >= 0 && var.lambda_success_feedback_sample_rate <= 100
    error_message = "Sample rate must be between 0 and 100."
  }
}

variable "lambda_failure_feedback_role_arn" {
  type        = string
  default     = ""
  description = "IAM role ARN for Lambda failure feedback"
}

variable "sqs_success_feedback_role_arn" {
  type        = string
  default     = ""
  description = "IAM role ARN for SQS success feedback"
}

variable "sqs_success_feedback_sample_rate" {
  type        = number
  default     = 100
  description = "Percentage of successful SQS deliveries to sample (0-100)"
  nullable    = false

  validation {
    condition     = var.sqs_success_feedback_sample_rate >= 0 && var.sqs_success_feedback_sample_rate <= 100
    error_message = "Sample rate must be between 0 and 100."
  }
}

variable "sqs_failure_feedback_role_arn" {
  type        = string
  default     = ""
  description = "IAM role ARN for SQS failure feedback"
}

variable "firehose_success_feedback_role_arn" {
  type        = string
  default     = ""
  description = "IAM role ARN for Firehose success feedback"
}

variable "firehose_success_feedback_sample_rate" {
  type        = number
  default     = 100
  description = "Percentage of successful Firehose deliveries to sample (0-100)"
  nullable    = false

  validation {
    condition     = var.firehose_success_feedback_sample_rate >= 0 && var.firehose_success_feedback_sample_rate <= 100
    error_message = "Sample rate must be between 0 and 100."
  }
}

variable "firehose_failure_feedback_role_arn" {
  type        = string
  default     = ""
  description = "IAM role ARN for Firehose failure feedback"
}

variable "application_success_feedback_role_arn" {
  type        = string
  default     = ""
  description = "IAM role ARN for mobile push success feedback"
}

variable "application_success_feedback_sample_rate" {
  type        = number
  default     = 100
  description = "Percentage of successful mobile push deliveries to sample (0-100)"
  nullable    = false

  validation {
    condition     = var.application_success_feedback_sample_rate >= 0 && var.application_success_feedback_sample_rate <= 100
    error_message = "Sample rate must be between 0 and 100."
  }
}

variable "application_failure_feedback_role_arn" {
  type        = string
  default     = ""
  description = "IAM role ARN for mobile push failure feedback"
}

# ==============================================================================
# SUBSCRIPTIONS
# ==============================================================================

variable "email_subscriptions" {
  type = map(object({
    endpoint                        = string
    raw_message_delivery            = optional(bool, false)
    filter_policy                   = optional(string, "")
    filter_policy_scope             = optional(string, "MessageAttributes")
    redrive_policy                  = optional(string, "")
    delivery_policy                 = optional(string, "")
    confirmation_timeout_in_minutes = optional(number, 1)
  }))
  default     = {}
  description = "Map of email subscriptions"
  nullable    = false

  validation {
    condition = alltrue([
      for sub in var.email_subscriptions : contains(["MessageAttributes", "MessageBody"], sub.filter_policy_scope)
    ])
    error_message = "Filter policy scope must be either MessageAttributes or MessageBody."
  }
}

variable "sms_subscriptions" {
  type = map(object({
    endpoint            = string
    filter_policy       = optional(string, "")
    filter_policy_scope = optional(string, "MessageAttributes")
    redrive_policy      = optional(string, "")
    delivery_policy     = optional(string, "")
  }))
  default     = {}
  description = "Map of SMS subscriptions (phone numbers in E.164 format)"
  nullable    = false

  validation {
    condition = alltrue([
      for sub in var.sms_subscriptions : can(regex("^\\+[1-9]\\d{1,14}$", sub.endpoint))
    ])
    error_message = "SMS endpoints must be valid phone numbers in E.164 format (e.g., +1234567890)."
  }
}

variable "lambda_subscriptions" {
  type = map(object({
    endpoint             = string
    raw_message_delivery = optional(bool, false)
    filter_policy        = optional(string, "")
    filter_policy_scope  = optional(string, "MessageAttributes")
    redrive_policy       = optional(string, "")
    delivery_policy      = optional(string, "")
  }))
  default     = {}
  description = "Map of Lambda function subscriptions (ARNs)"
  nullable    = false

  validation {
    condition = alltrue([
      for sub in var.lambda_subscriptions : can(regex("^arn:aws:lambda:", sub.endpoint))
    ])
    error_message = "Lambda endpoints must be valid Lambda function ARNs."
  }
}

variable "sqs_subscriptions" {
  type = map(object({
    endpoint             = string
    raw_message_delivery = optional(bool, false)
    filter_policy        = optional(string, "")
    filter_policy_scope  = optional(string, "MessageAttributes")
    redrive_policy       = optional(string, "")
  }))
  default     = {}
  description = "Map of SQS queue subscriptions (ARNs or URLs)"
  nullable    = false
}

variable "http_subscriptions" {
  type = map(object({
    endpoint                        = string
    raw_message_delivery            = optional(bool, false)
    filter_policy                   = optional(string, "")
    filter_policy_scope             = optional(string, "MessageAttributes")
    redrive_policy                  = optional(string, "")
    delivery_policy                 = optional(string, "")
    confirmation_timeout_in_minutes = optional(number, 1)
  }))
  default     = {}
  description = "Map of HTTP/HTTPS subscriptions"
  nullable    = false

  validation {
    condition = alltrue([
      for sub in var.http_subscriptions : can(regex("^https?://", sub.endpoint))
    ])
    error_message = "HTTP endpoints must be valid HTTP or HTTPS URLs."
  }
}

variable "firehose_subscriptions" {
  type = map(object({
    endpoint              = string
    subscription_role_arn = string
    raw_message_delivery  = optional(bool, false)
    filter_policy         = optional(string, "")
    filter_policy_scope   = optional(string, "MessageAttributes")
    redrive_policy        = optional(string, "")
  }))
  default     = {}
  description = "Map of Kinesis Firehose subscriptions (ARNs)"
  nullable    = false

  validation {
    condition = alltrue([
      for sub in var.firehose_subscriptions : can(regex("^arn:aws:firehose:", sub.endpoint))
    ])
    error_message = "Firehose endpoints must be valid Kinesis Firehose ARNs."
  }
}

# ==============================================================================
# DATA PROTECTION POLICY
# ==============================================================================

variable "data_protection_policy" {
  type        = string
  default     = ""
  description = "JSON data protection policy for PII detection and redaction"
}

# ==============================================================================
# TOPIC POLICY
# ==============================================================================

variable "topic_policy" {
  type        = string
  default     = ""
  description = "JSON topic policy (if empty, a default policy will be created)"
}

variable "allow_publish_from_accounts" {
  type        = list(string)
  default     = []
  description = "List of AWS account IDs allowed to publish to this topic"
  nullable    = false

  validation {
    condition = alltrue([
      for account_id in var.allow_publish_from_accounts : can(regex("^[0-9]{12}$", account_id))
    ])
    error_message = "All account IDs must be 12-digit numbers."
  }
}

variable "allow_publish_from_services" {
  type        = list(string)
  default     = []
  description = "List of AWS services allowed to publish to this topic (e.g., 'cloudwatch.amazonaws.com', 's3.amazonaws.com')"
  nullable    = false
}
