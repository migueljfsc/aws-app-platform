###################### MODULE VARIABLES ######################

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

# ==============================================================================
# ANOMALY DETECTION CONFIGURATION
# ==============================================================================
variable "enable_anomaly_detection" {
  type        = bool
  default     = true
  description = "Whether to enable AWS Cost Anomaly Detection monitoring and alerting"
}

variable "anomaly_threshold_percentage" {
  type        = number
  default     = 10
  description = "The percentage threshold over expected cost (e.g., 10 for 10%) above which an anomaly alert is triggered"
}

# ==============================================================================
# BUDGET CONFIGURATION
# ==============================================================================

variable "budgets" {
  type = map(object({
    budget_type       = optional(string, "COST")
    limit_amount      = string
    limit_unit        = optional(string, "USD")
    time_unit         = optional(string, "MONTHLY")
    time_period_start = optional(string)
    time_period_end   = optional(string)
    cost_filters      = optional(map(list(string)), {})
    cost_tags         = optional(map(list(string)), {})

    cost_types = optional(object({
      include_credit             = optional(bool)
      include_discount           = optional(bool)
      include_other_subscription = optional(bool)
      include_recurring          = optional(bool)
      include_refund             = optional(bool)
      include_subscription       = optional(bool)
      include_support            = optional(bool)
      include_tax                = optional(bool, false)
      include_upfront            = optional(bool)
      use_amortized              = optional(bool)
      use_blended                = optional(bool)
    }), {})

    notifications = list(object({
      comparison_operator = string
      threshold           = number
      threshold_type      = optional(string, "PERCENTAGE")
      notification_type   = optional(string, "ACTUAL")
    }))
  }))

  description = "Map of budget definitions keyed by budget name"
  nullable    = false

  validation {
    condition     = length(var.budgets) > 0
    error_message = "At least one budget must be defined."
  }

  validation {
    condition = alltrue([
      for b in var.budgets : contains(
        ["COST", "USAGE", "RI_UTILIZATION", "RI_COVERAGE", "SAVINGS_PLANS_UTILIZATION", "SAVINGS_PLANS_COVERAGE"],
        b.budget_type
      )
    ])
    error_message = "Budget type must be one of: COST, USAGE, RI_UTILIZATION, RI_COVERAGE, SAVINGS_PLANS_UTILIZATION, SAVINGS_PLANS_COVERAGE."
  }

  validation {
    condition = alltrue([
      for b in var.budgets : contains(["MONTHLY", "QUARTERLY", "ANNUALLY"], b.time_unit)
    ])
    error_message = "Time unit must be one of: MONTHLY, QUARTERLY, ANNUALLY."
  }

  validation {
    condition = alltrue([
      for b in var.budgets : length(b.notifications) > 0
    ])
    error_message = "Each budget must have at least one notification."
  }

  validation {
    condition = alltrue(flatten([
      for b in var.budgets : [
        for n in b.notifications : contains(["GREATER_THAN", "LESS_THAN", "EQUAL_TO"], n.comparison_operator)
      ]
    ]))
    error_message = "Comparison operator must be one of: GREATER_THAN, LESS_THAN, EQUAL_TO."
  }

  validation {
    condition = alltrue(flatten([
      for b in var.budgets : [
        for n in b.notifications : contains(["PERCENTAGE", "ABSOLUTE_VALUE"], n.threshold_type)
      ]
    ]))
    error_message = "Threshold type must be one of: PERCENTAGE, ABSOLUTE_VALUE."
  }

  validation {
    condition = alltrue(flatten([
      for b in var.budgets : [
        for n in b.notifications : contains(["ACTUAL", "FORECASTED"], n.notification_type)
      ]
    ]))
    error_message = "Notification type must be one of: ACTUAL, FORECASTED."
  }
}

# ==============================================================================
# SNS NOTIFICATION CONFIGURATION
# ==============================================================================

variable "sns_email_subscriptions" {
  type = map(object({
    endpoint = string
  }))
  default     = {}
  description = "Map of email subscriptions for budget alert notifications"
  nullable    = false
}
