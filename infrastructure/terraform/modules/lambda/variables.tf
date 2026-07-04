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
  description = "The name of the service (e.g., 'webapp', 'api', 'analytics')"
  nullable    = false

  validation {
    condition     = var.service_name != ""
    error_message = "Service name cannot be empty."
  }
}

# ==============================================================================
# LAMBDA FUNCTIONS
# ==============================================================================

variable "functions" {
  type = map(object({
    # Lambda configuration
    description = optional(string, "")
    handler     = string
    runtime     = optional(string, "")

    # Code source (one of these must be provided)
    filename          = optional(string, "")
    s3_bucket         = optional(string, "")
    s3_key            = optional(string, "")
    s3_object_version = optional(string, "")
    image_uri         = optional(string, "")

    # Function settings
    timeout       = optional(number, 3)
    memory_size   = optional(number, 128)
    architectures = optional(list(string), ["x86_64"])

    # Environment variables
    environment_variables = optional(map(string), {})

    # VPC configuration
    vpc_config = optional(object({
      subnet_ids         = list(string)
      security_group_ids = list(string)
    }))

    # Execution role
    create_role = optional(bool, true)
    role_arn    = optional(string, "")

    # Additional IAM policies to attach
    policy_arns = optional(list(string), [])
    inline_policies = optional(map(object({
      policy_statements = list(object({
        effect    = string
        actions   = list(string)
        resources = list(string)
      }))
    })), {})

    # Dead Letter Queue
    dead_letter_config = optional(object({
      target_arn = string
    }))

    # Layers
    layers = optional(list(string), [])

    # Reserved concurrent executions
    reserved_concurrent_executions = optional(number, -1)

    # Provisioned concurrency
    provisioned_concurrent_executions = optional(number, 0)

    # Ephemeral storage
    ephemeral_storage_size = optional(number, 512)

    # CloudWatch Logs
    log_retention_days = optional(number, 7)

    # Tracing
    tracing_mode = optional(string, "PassThrough")

    # File system
    file_system_config = optional(object({
      arn              = string
      local_mount_path = string
    }))

    # Container image
    package_type = optional(string, "Zip")
    image_config = optional(object({
      command           = optional(list(string), [])
      entry_point       = optional(list(string), [])
      working_directory = optional(string, "")
    }))

    # API Gateway Integration (optional)
    api_gateway = optional(object({
      api_id   = optional(string, "")
      api_name = optional(string, "")
      api_type = string # REST or HTTP

      # REST API specific
      root_resource_id     = optional(string, "")
      request_validator_id = optional(string, "")

      # Routes
      routes = map(object({
        http_method = string
        path        = string

        # Authorization
        authorization_type = optional(string, "NONE")
        authorizer_id      = optional(string, "")
        api_key_required   = optional(bool, false)

        # Integration settings
        timeout_milliseconds   = optional(number, 29000)
        payload_format_version = optional(string, "2.0")

        # Request/Response handling
        request_parameters = optional(map(string), {})
        request_templates  = optional(map(string), {})
      }))
    }))

    # Event sources
    event_sources = optional(map(object({
      type = string # sqs, dynamodb, kinesis, msk, kafka, s3, sns

      # Common
      enabled = optional(bool, true)

      # SQS/DynamoDB/Kinesis/MSK/Kafka
      event_source_arn  = optional(string, "")
      batch_size        = optional(number, 10)
      starting_position = optional(string, "") # LATEST, TRIM_HORIZON, AT_TIMESTAMP

      # Advanced settings
      maximum_batching_window_in_seconds = optional(number, 0)
      maximum_retry_attempts             = optional(number, -1)
      maximum_record_age_in_seconds      = optional(number, -1)
      bisect_batch_on_function_error     = optional(bool, false)
      parallelization_factor             = optional(number, 1)

      # Destinations
      on_failure_destination_arn = optional(string, "")

      # Filter criteria
      filter_criteria = optional(list(object({
        pattern = string
      })), [])
    })), {})

    # Permissions (for services to invoke this Lambda)
    permissions = optional(map(object({
      principal      = string
      source_arn     = optional(string, "")
      source_account = optional(string, "")
    })), {})

    # Aliases
    aliases = optional(map(object({
      description      = optional(string, "")
      function_version = optional(string, "$LATEST")
      routing_config = optional(object({
        additional_version_weights = map(number)
      }))
    })), {})

    # Tags
    tags = optional(map(string), {})
  }))
  description = "Map of Lambda functions to create"
  nullable    = false

  validation {
    condition = alltrue([
      for fn in var.functions : contains(
        ["nodejs18.x", "nodejs20.x", "python3.9", "python3.10", "python3.11", "python3.12", "java11", "java17", "java21", "dotnet6", "dotnet8", "ruby3.2", "ruby3.3", "provided.al2", "provided.al2023"],
        fn.runtime
      ) || fn.package_type == "Image"
    ])
    error_message = "Runtime must be a valid Lambda runtime."
  }

  validation {
    condition = alltrue([
      for fn in var.functions : fn.timeout >= 1 && fn.timeout <= 900
    ])
    error_message = "Timeout must be between 1 and 900 seconds."
  }

  validation {
    condition = alltrue([
      for fn in var.functions : fn.memory_size >= 128 && fn.memory_size <= 10240
    ])
    error_message = "Memory size must be between 128 and 10240 MB."
  }

  validation {
    condition = alltrue([
      for fn in var.functions : fn.ephemeral_storage_size >= 512 && fn.ephemeral_storage_size <= 10240
    ])
    error_message = "Ephemeral storage must be between 512 and 10240 MB."
  }

  validation {
    condition = alltrue([
      for fn in var.functions : contains(["PassThrough", "Active"], fn.tracing_mode)
    ])
    error_message = "Tracing mode must be PassThrough or Active."
  }

  validation {
    condition = alltrue([
      for fn in var.functions : contains(["Zip", "Image"], fn.package_type)
    ])
    error_message = "Package type must be Zip or Image."
  }

  validation {
    condition = alltrue([
      for fn in var.functions : fn.log_retention_days == null || contains(
        [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653],
        fn.log_retention_days
      )
    ])
    error_message = "Log retention days must be a valid CloudWatch Logs retention period."
  }

  validation {
    condition = alltrue(flatten([
      for fn_key, fn in var.functions : [
        for arch in fn.architectures : contains(["x86_64", "arm64"], arch)
      ]
    ]))
    error_message = "Architecture must be x86_64 or arm64."
  }

  validation {
    condition = alltrue([
      for fn in var.functions :
      fn.api_gateway == null ? true : (
        (
          try(fn.api_gateway.api_id, "") != "" ||
          try(fn.api_gateway.api_name, "") != ""
        )
      )
    ])
    error_message = "For functions with api_gateway defined, either api_id or api_name must be set."
  }
}
