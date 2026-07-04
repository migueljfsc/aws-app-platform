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
# DATABASE ENGINE CONFIGURATION
# ==============================================================================

variable "engine" {
  type        = string
  description = "Database engine (aurora-postgresql, aurora-mysql, aurora, postgres, mysql, mariadb, oracle-ee, oracle-se2, sqlserver-ex, sqlserver-web, sqlserver-se, sqlserver-ee)"
  nullable    = false

  validation {
    condition = contains([
      "aurora", "aurora-mysql", "aurora-postgresql",
      "postgres", "mysql", "mariadb",
      "oracle-ee", "oracle-se2", "oracle-se1", "oracle-se",
      "sqlserver-ex", "sqlserver-web", "sqlserver-se", "sqlserver-ee"
    ], var.engine)
    error_message = "Engine must be a valid RDS engine type."
  }
}

variable "engine_version" {
  type        = string
  description = "Database engine version (e.g., '15.4' for PostgreSQL, '8.0.35' for MySQL)"
  nullable    = false
}

variable "instance_class" {
  type        = string
  description = "Instance type (e.g., 'db.t3.micro', 'db.r6g.large', 'db.serverless')"
  nullable    = false

  validation {
    condition     = can(regex("^db\\.", var.instance_class))
    error_message = "Instance class must start with 'db.' (e.g., 'db.t3.micro')."
  }
}

variable "instance_count" {
  type        = number
  default     = 1
  description = "Number of Aurora cluster instances to create (ignored for non-Aurora engines)"
  nullable    = false
}

# ==============================================================================
# DATABASE CREDENTIALS
# ==============================================================================

variable "database_name" {
  type        = string
  default     = ""
  description = "Initial database name to create"
}

variable "master_username" {
  type        = string
  default     = "admin"
  description = "Master username for the database"
  nullable    = false

  validation {
    condition     = length(var.master_username) >= 1 && length(var.master_username) <= 16
    error_message = "Master username must be between 1 and 16 characters."
  }
}

variable "manage_master_user_password" {
  type        = bool
  default     = true
  description = "Use AWS Secrets Manager to manage the master password automatically"
  nullable    = false
}

variable "master_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Master password (required if manage_master_user_password is false, min 8 characters)"

  validation {
    condition     = var.master_password == "" || length(var.master_password) >= 8
    error_message = "Master password must be at least 8 characters if provided."
  }
}

variable "master_user_secret_kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key ID for encrypting the master user secret in Secrets Manager"
}

# ==============================================================================
# NETWORK CONFIGURATION
# ==============================================================================

variable "vpc_name" {
  type        = string
  default     = ""
  description = "Name of the VPC (defaults to '{deploy_context}-vpc' if empty)"
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of subnet IDs for the DB subnet group (use private subnets)"
}

variable "db_subnet_group_name" {
  type        = string
  default     = ""
  description = "Name of existing DB subnet group (leave empty to create new one)"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of VPC security group IDs to attach"
  nullable    = false
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "Make the database publicly accessible (NOT recommended for production)"
  nullable    = false
}

variable "port" {
  type        = number
  default     = 0
  description = "Database port (defaults: PostgreSQL=5432, MySQL=3306)"

  validation {
    condition     = var.port == 0 || (var.port >= 1150 && var.port <= 65535)
    error_message = "Port must be 0 (auto-detect) or between 1150 and 65535."
  }
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Enable Multi-AZ deployment for non-Aurora instances (ignored for Aurora)"
  nullable    = false
}

# ==============================================================================
# STORAGE CONFIGURATION
# ==============================================================================

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Enable storage encryption (required for production)"
  nullable    = false
}

variable "kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key ID/ARN for storage encryption (leave empty for AWS managed key)"
}

variable "storage_type" {
  type        = string
  default     = "gp3"
  description = "Storage type for non-Aurora instances (gp2, gp3, io1, io2, standard)"
  nullable    = false

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "standard"], var.storage_type)
    error_message = "storage_type must be one of: gp2, gp3, io1, io2, standard."
  }
}

variable "allocated_storage" {
  type        = number
  default     = 20
  description = "Allocated storage in GiB for non-Aurora instances (ignored for Aurora)"
  nullable    = false
}

variable "iops" {
  type        = number
  default     = 0
  description = "IOPS for io1/io2 storage types (0 = not set)"
  nullable    = false
}

variable "storage_throughput" {
  type        = number
  default     = 0
  description = "Throughput in MiB/s for gp3 storage type (0 = not set)"
  nullable    = false
}

# ==============================================================================
# BACKUP CONFIGURATION
# ==============================================================================

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "Backup retention period in days (1-35)"
  nullable    = false

  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 1 and 35 days."
  }
}

variable "backup_window" {
  type        = string
  default     = "03:00-04:00"
  description = "Preferred backup window in UTC (format: HH:MM-HH:MM)"
  nullable    = false

  validation {
    condition     = can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]-([0-1][0-9]|2[0-3]):[0-5][0-9]$", var.backup_window))
    error_message = "Backup window must be in HH:MM-HH:MM format (e.g., '03:00-04:00')."
  }
}

variable "maintenance_window" {
  type        = string
  default     = "sun:04:00-sun:05:00"
  description = "Preferred maintenance window (format: ddd:HH:MM-ddd:HH:MM)"
  nullable    = false
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  description = "Skip final snapshot when destroying (NOT recommended for production)"
  nullable    = false
}

variable "final_snapshot_identifier_prefix" {
  type        = string
  default     = "final"
  description = "Prefix for final snapshot identifier"
  nullable    = false
}

variable "copy_tags_to_snapshot" {
  type        = bool
  default     = true
  description = "Copy tags to snapshots"
  nullable    = false
}

# ==============================================================================
# PERFORMANCE & MONITORING
# ==============================================================================

variable "performance_insights_enabled" {
  type        = bool
  default     = true
  description = "Enable Performance Insights for advanced monitoring"
  nullable    = false
}

variable "performance_insights_retention_period" {
  type        = number
  default     = 7
  description = "Performance Insights retention period in days"
  nullable    = false

  validation {
    condition = contains([
      7, 31, 62, 93, 124, 155, 186, 217, 248, 279, 310, 341, 372, 403, 434, 465, 496, 527, 558, 589, 620, 651, 682, 713, 731
    ], var.performance_insights_retention_period)
    error_message = "Performance Insights retention must be one of the allowed values."
  }
}

variable "performance_insights_kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key ID for Performance Insights encryption"
}

variable "monitoring_interval" {
  type        = number
  default     = 60
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  nullable    = false

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "monitoring_role_arn" {
  type        = string
  default     = ""
  description = "IAM role ARN for enhanced monitoring (leave empty to create automatically)"
}

# ==============================================================================
# PARAMETER GROUPS
# ==============================================================================

variable "parameter_group_name" {
  type        = string
  default     = ""
  description = "Name for the DB instance parameter group (leave empty to skip creation)"
}

variable "cluster_parameter_group_name" {
  type        = string
  default     = ""
  description = "Name for the DB cluster parameter group (Aurora only, leave empty to skip creation)"
}

variable "cluster_parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default     = []
  description = "Database parameters to set in the cluster parameter group (Aurora only)"
  nullable    = false
}

variable "parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default     = []
  description = "Database parameters to set in the instance parameter group"
  nullable    = false
}

variable "parameter_group_family" {
  type        = string
  default     = ""
  description = "Parameter group family (e.g., 'aurora-postgresql15', 'postgres15', 'mysql8.0')"
}

# ==============================================================================
# ADVANCED CONFIGURATION
# ==============================================================================

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "Automatically upgrade to new minor versions during maintenance window"
  nullable    = false
}

variable "allow_major_version_upgrade" {
  type        = bool
  default     = false
  description = "Allow major version upgrades"
  nullable    = false
}

variable "apply_immediately" {
  type        = bool
  default     = false
  description = "Apply changes immediately instead of during maintenance window (may cause downtime)"
  nullable    = false
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "Enable deletion protection (recommended for production)"
  nullable    = false
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = false
  description = "Enable IAM database authentication"
  nullable    = false
}

variable "ca_cert_identifier" {
  type        = string
  default     = ""
  description = "Certificate authority identifier for SSL connections"
}

# ==============================================================================
# RESTORE & SNAPSHOTS
# ==============================================================================

variable "snapshot_identifier" {
  type        = string
  default     = ""
  description = "Snapshot ID to restore from (creates DB from snapshot instead of new DB)"
}

variable "restore_to_point_in_time" {
  type = object({
    source_cluster_identifier  = string
    restore_to_time            = optional(string)
    use_latest_restorable_time = optional(bool, false)
  })
  default     = null
  description = "Restore from point-in-time backup. source_cluster_identifier is used as the source instance identifier for non-Aurora engines."
}

# ==============================================================================
# ROUTE 53 CONFIGURATION
# ==============================================================================

variable "create_route53_record" {
  type        = bool
  default     = true
  description = "Whether to create a Route 53 record for the RDS instance or cluster"
  nullable    = false
}

variable "route53_domain_name" {
  type        = string
  default     = ""
  description = "The domain name of the Route 53 hosted zone"
}

variable "route53_record_name" {
  type        = string
  default     = ""
  description = "The record name to create (defaults to '{service_name}-{deploy_context}' if empty)"
}

variable "route53_private_zone" {
  type        = bool
  default     = true
  description = "Whether the Route 53 hosted zone is private"
  nullable    = false
}
