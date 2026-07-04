
###################### MODULE VARIABLES ######################

# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================
variable "deploy_context" {
  type        = string
  description = "The deployment context (e.g., 'dev-euw3', 'stg-euw3')"
  nullable    = false

  validation {
    condition     = var.deploy_context != ""
    error_message = "Deploy context cannot be empty."
  }
}

variable "service_name" {
  type        = string
  description = "The name of the service (e.g., 'session-cache', 'app-cache')"
  nullable    = false

  validation {
    condition     = var.service_name != ""
    error_message = "Service name cannot be empty."
  }
}

# ==============================================================================
# ENGINE CONFIGURATION
# ==============================================================================

variable "engine" {
  type        = string
  description = "Cache engine (valkey, redis, or memcached)"
  nullable    = false

  validation {
    condition     = contains(["valkey", "redis", "memcached"], var.engine)
    error_message = "Engine must be 'valkey', 'redis', or 'memcached'."
  }
}

variable "engine_version" {
  type        = string
  description = "Cache engine version (e.g., '7.2' for Valkey, '7.1' for Redis, '1.6.22' for Memcached)"
  nullable    = false
}

variable "node_type" {
  type        = string
  description = "Instance type for cache nodes (e.g., 'cache.t4g.micro', 'cache.r7g.large')"
  nullable    = false

  validation {
    condition     = can(regex("^cache\\.", var.node_type))
    error_message = "Node type must start with 'cache.' (e.g., 'cache.t4g.micro')."
  }
}

# ==============================================================================
# CLUSTER TOPOLOGY
# ==============================================================================

variable "num_cache_nodes" {
  type        = number
  default     = 1
  description = "Number of cache nodes. For Redis replication group, this controls replicas per shard (0-5). For Memcached, the number of nodes in the cluster (1-40)."
  nullable    = false

  validation {
    condition     = var.num_cache_nodes >= 0 && var.num_cache_nodes <= 40
    error_message = "Number of cache nodes must be between 0 and 40."
  }
}

variable "num_node_groups" {
  type        = number
  default     = 1
  description = "Number of node groups (shards) for Redis cluster mode. Ignored for Memcached."
  nullable    = false

  validation {
    condition     = var.num_node_groups >= 1 && var.num_node_groups <= 500
    error_message = "Number of node groups must be between 1 and 500."
  }
}

# ==============================================================================
# REDIS REPLICATION & HIGH AVAILABILITY
# ==============================================================================

variable "description" {
  type        = string
  default     = ""
  description = "Description for the Redis replication group"
}

variable "automatic_failover_enabled" {
  type        = bool
  default     = false
  description = "Enable automatic failover for Redis (requires num_cache_nodes >= 1 or num_node_groups >= 2)"
  nullable    = false
}

variable "multi_az_enabled" {
  type        = bool
  default     = false
  description = "Enable Multi-AZ for Redis with automatic failover"
  nullable    = false
}

# ==============================================================================
# NETWORK CONFIGURATION
# ==============================================================================

variable "vpc_name" {
  type        = string
  default     = ""
  description = "Name of the VPC (defaults to 'app-{deploy_context}-vpc' if empty)"
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of subnet IDs for the cache subnet group (use private subnets)"
}

variable "subnet_group_name" {
  type        = string
  default     = ""
  description = "Name of existing ElastiCache subnet group (leave empty to create new one)"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of VPC security group IDs to attach"
  nullable    = false
}

variable "port" {
  type        = number
  default     = 0
  description = "Cache port (defaults: Redis=6379, Memcached=11211)"

  validation {
    condition     = var.port == 0 || (var.port >= 1024 && var.port <= 65535)
    error_message = "Port must be 0 (auto-detect) or between 1024 and 65535."
  }
}

# ==============================================================================
# ENCRYPTION
# ==============================================================================

variable "at_rest_encryption_enabled" {
  type        = bool
  default     = true
  description = "Enable encryption at rest (Redis only)"
  nullable    = false
}

variable "transit_encryption_enabled" {
  type        = bool
  default     = false
  description = "Enable in-transit encryption (Redis only)"
  nullable    = false
}

variable "transit_encryption_mode" {
  type        = string
  default     = "preferred"
  description = "Transit encryption mode: 'preferred' or 'required' (Redis 7.0+)"
  nullable    = false

  validation {
    condition     = contains(["preferred", "required"], var.transit_encryption_mode)
    error_message = "Transit encryption mode must be 'preferred' or 'required'."
  }
}

variable "kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key ID for at-rest encryption (leave empty for AWS managed key)"
}

variable "auth_token" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Auth token (password) for Redis AUTH (requires transit_encryption_enabled = true)"

  validation {
    condition     = var.auth_token == "" || length(var.auth_token) >= 16
    error_message = "Auth token must be at least 16 characters if provided."
  }
}

# ==============================================================================
# MAINTENANCE & SNAPSHOTS
# ==============================================================================

variable "maintenance_window" {
  type        = string
  default     = "sun:04:00-sun:05:00"
  description = "Preferred maintenance window (format: ddd:HH:MM-ddd:HH:MM)"
  nullable    = false
}

variable "snapshot_window" {
  type        = string
  default     = "03:00-04:00"
  description = "Daily time range for Redis snapshots in UTC (format: HH:MM-HH:MM)"
  nullable    = false

  validation {
    condition     = can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]-([0-1][0-9]|2[0-3]):[0-5][0-9]$", var.snapshot_window))
    error_message = "Snapshot window must be in HH:MM-HH:MM format (e.g., '03:00-04:00')."
  }
}

variable "snapshot_retention_limit" {
  type        = number
  default     = 0
  description = "Number of days to retain Redis snapshots (0 = disabled, max 35)"
  nullable    = false

  validation {
    condition     = var.snapshot_retention_limit >= 0 && var.snapshot_retention_limit <= 35
    error_message = "Snapshot retention limit must be between 0 and 35 days."
  }
}

variable "final_snapshot_identifier" {
  type        = string
  default     = ""
  description = "Name of final snapshot when deleting Redis replication group (leave empty to skip)"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "Automatically upgrade to new minor versions during maintenance window"
  nullable    = false
}

variable "apply_immediately" {
  type        = bool
  default     = false
  description = "Apply changes immediately instead of during maintenance window"
  nullable    = false
}

# ==============================================================================
# PARAMETER GROUPS
# ==============================================================================

variable "parameter_group_name" {
  type        = string
  default     = ""
  description = "Name of existing parameter group (leave empty to create new one)"
}

variable "parameter_group_family" {
  type        = string
  default     = ""
  description = "Parameter group family (e.g., 'redis7', 'memcached1.6')"
}

variable "parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "Cache parameters to set in the parameter group"
  nullable    = false
}

# ==============================================================================
# NOTIFICATIONS
# ==============================================================================

variable "notification_topic_arn" {
  type        = string
  default     = ""
  description = "SNS topic ARN to send ElastiCache notifications to"
}

# ==============================================================================
# LOG DELIVERY
# ==============================================================================

variable "log_delivery_configurations" {
  type = list(object({
    log_type         = string
    destination_type = string
    destination      = string
    log_format       = optional(string, "json")
  }))
  default     = []
  description = "Log delivery configurations (log_type: slow-log or engine-log; destination_type: cloudwatch-logs or kinesis-firehose)"
  nullable    = false

  validation {
    condition = alltrue([
      for config in var.log_delivery_configurations : contains(["slow-log", "engine-log"], config.log_type)
    ])
    error_message = "Log type must be 'slow-log' or 'engine-log'."
  }

  validation {
    condition = alltrue([
      for config in var.log_delivery_configurations : contains(["cloudwatch-logs", "kinesis-firehose"], config.destination_type)
    ])
    error_message = "Destination type must be 'cloudwatch-logs' or 'kinesis-firehose'."
  }
}

# ==============================================================================
# DNS
# ==============================================================================

variable "route53_zone_name" {
  type        = string
  default     = ""
  description = "Route53 private hosted zone name. If set, a CNAME record is created pointing to the ElastiCache endpoint."
}
