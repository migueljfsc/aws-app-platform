# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================
variable "deploy_context" {
  type        = string
  description = "The context of the deploy"
  nullable    = false
  validation {
    condition     = var.deploy_context != ""
    error_message = "Module variable deploy_context cannot be empty."
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


variable "vpc_name" {
  type        = string
  default     = ""
  description = "(Optional) VPC name, defaults to context VPC"
}

variable "security_group_names" {
  type        = list(string)
  default     = []
  description = "(Optional) List of security group names (tag:Name) to attach. Defaults to 'app-<deploy_context>-ecs-ec2' or 'app-<deploy_context>-ecs-fargate' based on launch type."
  nullable    = false
}

variable "ec2_template_tags" {
  type        = map(string)
  description = "Additional tags to apply to EC2 launch template and Auto Scaling Group resources (EC2 launch type only)"
  nullable    = false
  default     = {}
  validation {
    condition     = length([for tag_value in values(var.ec2_template_tags) : tag_value if tag_value == ""]) == 0
    error_message = "Tag values cannot be empty strings."
  }
}

# ==============================================================================
# LAUNCH TYPE & COMPUTE CONFIGURATION
# ==============================================================================

variable "launch_type" {
  type        = string
  default     = "FARGATE"
  description = "ECS launch type (FARGATE or EC2)"
  nullable    = false

  validation {
    condition     = contains(["FARGATE", "EC2"], var.launch_type)
    error_message = "Launch type must be either FARGATE or EC2."
  }
}

variable "network_mode" {
  type        = string
  default     = "awsvpc"
  description = "ECS task network mode (awsvpc, bridge, host, or none). Fargate requires awsvpc."
  nullable    = false

  validation {
    condition     = contains(["awsvpc", "bridge", "host", "none"], var.network_mode)
    error_message = "Network mode must be one of: awsvpc, bridge, host, none."
  }
}

# ==============================================================================
# ECS CLUSTER CONFIGURATION & DISCOVERY
# ==============================================================================
variable "create_cluster" {
  type        = bool
  default     = false
  description = "Whether to create a new ECS cluster or use an existing one (if false, cluster_name must be provided)"
  nullable    = false
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "(Optional) Name of the ECS cluster to use (required if create_cluster is false)"
  nullable    = false
  validation {
    condition     = var.create_cluster || (!var.create_cluster && var.cluster_name != "")
    error_message = "If create_cluster is false, cluster_name must be provided."
  }
}

# ==============================================================================
# CONTAINER CONFIGURATION - BASIC
# ==============================================================================

variable "container_image" {
  type        = string
  default     = ""
  description = "Docker image URI for the container (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:latest)"
  nullable    = false
}

variable "container_image_tag" {
  type        = string
  default     = "latest"
  description = "Docker image tag for the container"
  nullable    = false
}

variable "container_port" {
  type        = number
  default     = 80
  description = "Port the container listens on"
  nullable    = false

  validation {
    condition     = var.container_port > 0 && var.container_port <= 65535
    error_message = "Container port must be between 1 and 65535."
  }
}

variable "container_cpu" {
  type        = number
  default     = 256
  description = "CPU units for the container (1024 = 1 vCPU). For Fargate, set at task level. For EC2, this is a soft reservation."
  nullable    = false

  validation {
    condition     = var.container_cpu >= 0
    error_message = "Container CPU must be a positive number."
  }
}

variable "container_memory" {
  type        = number
  default     = 512
  description = "Memory in MB. For Fargate, set at task level. For EC2, this is a soft reservation."
  nullable    = false

  validation {
    condition     = var.container_memory > 0
    error_message = "Container memory must be greater than 0."
  }
}

variable "container_memory_hard_limit" {
  type        = number
  default     = null
  description = "Hard memory limit in MB (EC2 only). If not set, defaults to 2x container_memory."
}

# ==============================================================================
# CONTAINER CONFIGURATION - RUNTIME
# ==============================================================================

variable "container_environment_variables" {
  type        = map(string)
  default     = {}
  description = "Environment variables to pass to the container"
  nullable    = false
}

variable "container_secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default     = []
  description = "Secrets from AWS Secrets Manager or SSM Parameter Store (e.g., [{name = \"DB_PASSWORD\", valueFrom = \"arn:aws:secretsmanager:...\"}])"
  nullable    = false
}

variable "container_entrypoint" {
  type        = list(string)
  default     = null
  description = "Container entrypoint override (e.g., [\"/bin/sh\", \"-c\"])"
}

variable "container_command" {
  type        = list(string)
  default     = null
  description = "Container command override (e.g., [\"echo\", \"hello\"])"
}

variable "container_working_directory" {
  type        = string
  default     = null
  description = "Working directory inside the container"
}

variable "container_user" {
  type        = string
  default     = null
  description = "User to run the container as (e.g., \"1000:1000\" or \"www-data\")"
}

variable "container_hostname" {
  type        = string
  default     = null
  description = "Hostname for the container"
}

variable "container_readonly_rootfs" {
  type        = bool
  default     = false
  description = "Mount the container's root filesystem as read-only"
  nullable    = false
}

variable "container_interactive" {
  type        = bool
  default     = false
  description = "Keep STDIN open even if not attached"
  nullable    = false
}

variable "container_pseudo_terminal" {
  type        = bool
  default     = false
  description = "Allocate a pseudo-TTY"
  nullable    = false
}

# ==============================================================================
# CONTAINER CONFIGURATION - HEALTH & DEPENDENCIES
# ==============================================================================

variable "container_health_check" {
  type = object({
    command      = list(string)
    interval     = optional(number, 30)
    timeout      = optional(number, 5)
    retries      = optional(number, 3)
    start_period = optional(number, 0)
  })
  default     = null
  description = "Container-level health check (e.g., {command = [\"CMD-SHELL\", \"curl -f http://localhost/health || exit 1\"]})"
}

variable "container_depends_on" {
  type = list(object({
    containerName = string
    condition     = string
  }))
  default     = []
  description = "Container startup dependencies (e.g., [{containerName = \"datadog-agent\", condition = \"START\"}])"
  nullable    = false
}

# ==============================================================================
# CONTAINER CONFIGURATION - STORAGE & VOLUMES
# ==============================================================================

variable "container_mount_points" {
  type = list(object({
    sourceVolume  = string
    containerPath = string
    readOnly      = optional(bool, false)
  }))
  default     = []
  description = "Volume mount points for the container"
  nullable    = false
}

# ==============================================================================
# CONTAINER CONFIGURATION - NETWORKING
# ==============================================================================

variable "container_dns_servers" {
  type        = list(string)
  default     = []
  description = "Custom DNS servers for the container"
  nullable    = false
}

variable "container_dns_search_domains" {
  type        = list(string)
  default     = []
  description = "DNS search domains for the container"
  nullable    = false
}

variable "container_extra_hosts" {
  type = list(object({
    hostname  = string
    ipAddress = string
  }))
  default     = []
  description = "Additional entries to add to /etc/hosts (e.g., [{hostname = \"db.local\", ipAddress = \"10.0.1.5\"}])"
  nullable    = false
}

# ==============================================================================
# CONTAINER CONFIGURATION - ADVANCED LINUX
# ==============================================================================

variable "container_privileged" {
  type        = bool
  default     = false
  description = "Run container in privileged mode (EC2 only, not allowed in Fargate)"
  nullable    = false
}

variable "container_ulimits" {
  type = list(object({
    name      = string
    softLimit = number
    hardLimit = number
  }))
  default     = []
  description = "ulimit settings for the container (e.g., [{name = \"nofile\", softLimit = 1024, hardLimit = 2048}])"
  nullable    = false
}

variable "container_system_controls" {
  type = list(object({
    namespace = string
    value     = string
  }))
  default     = []
  description = "Kernel parameters to set (e.g., [{namespace = \"net.ipv4.tcp_keepalive_time\", value = \"600\"}])"
  nullable    = false
}

variable "container_linux_parameters" {
  type = object({
    capabilities = optional(object({
      add  = optional(list(string))
      drop = optional(list(string))
    }))
    devices = optional(list(object({
      hostPath      = string
      containerPath = optional(string)
      permissions   = optional(list(string))
    })))
    initProcessEnabled = optional(bool)
    maxSwap            = optional(number)
    sharedMemorySize   = optional(number)
    swappiness         = optional(number)
    tmpfs = optional(list(object({
      containerPath = string
      size          = number
      mountOptions  = optional(list(string))
    })))
  })
  default     = null
  description = "Linux-specific container configuration (capabilities, devices, swap, tmpfs, etc.)"
}

variable "container_docker_labels" {
  type        = map(string)
  default     = {}
  description = "Docker labels to apply to the container"
  nullable    = false
}

variable "key_name" {
  type        = string
  default     = null
  description = "(Optional) Name of the SSM Parameter Store parameter that contains the key pair name for EC2 instances"
}

# ==============================================================================
# CONTAINER CONFIGURATION - LOGGING & MONITORING
# ==============================================================================

variable "container_firelens_configuration" {
  type = object({
    type    = string
    options = optional(map(string))
  })
  default     = null
  description = "FireLens log router configuration (e.g., {type = \"fluentbit\", options = {config-file-type = \"file\"}})"
}

variable "enable_cloudwatch_logs" {
  type        = bool
  default     = true
  description = "Create a CloudWatch log group and configure containers to send logs via awslogs driver"
  nullable    = false
}

variable "cloudwatch_log_retention_days" {
  type        = number
  default     = 30
  description = "Number of days to retain CloudWatch logs"
  nullable    = false

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.cloudwatch_log_retention_days)
    error_message = "Log retention must be a valid CloudWatch retention value (0 = never expire)."
  }
}

variable "cloudwatch_log_stream_prefix" {
  type        = string
  default     = "ecs"
  description = "Prefix for CloudWatch log stream names"
  nullable    = false
}

variable "enable_cloudwatch_alarms" {
  type        = bool
  default     = false
  description = "Create CloudWatch metric alarms for ECS service CPU and memory utilization"
  nullable    = false
}

variable "cloudwatch_cpu_alarm_threshold" {
  type        = number
  default     = 80
  description = "CPU utilization percentage threshold for the high CPU alarm"
  nullable    = false

  validation {
    condition     = var.cloudwatch_cpu_alarm_threshold > 0 && var.cloudwatch_cpu_alarm_threshold <= 100
    error_message = "CPU alarm threshold must be between 1 and 100."
  }
}

variable "cloudwatch_cpu_alarm_evaluation_periods" {
  type        = number
  default     = 3
  description = "Number of evaluation periods for the CPU alarm"
  nullable    = false

  validation {
    condition     = var.cloudwatch_cpu_alarm_evaluation_periods >= 1
    error_message = "Evaluation periods must be at least 1."
  }
}

variable "cloudwatch_cpu_alarm_period" {
  type        = number
  default     = 300
  description = "Period in seconds for the CPU alarm metric evaluation"
  nullable    = false

  validation {
    condition     = var.cloudwatch_cpu_alarm_period >= 60
    error_message = "Alarm period must be at least 60 seconds."
  }
}

variable "cloudwatch_memory_alarm_threshold" {
  type        = number
  default     = 80
  description = "Memory utilization percentage threshold for the high memory alarm"
  nullable    = false

  validation {
    condition     = var.cloudwatch_memory_alarm_threshold > 0 && var.cloudwatch_memory_alarm_threshold <= 100
    error_message = "Memory alarm threshold must be between 1 and 100."
  }
}

variable "cloudwatch_memory_alarm_evaluation_periods" {
  type        = number
  default     = 3
  description = "Number of evaluation periods for the memory alarm"
  nullable    = false

  validation {
    condition     = var.cloudwatch_memory_alarm_evaluation_periods >= 1
    error_message = "Evaluation periods must be at least 1."
  }
}

variable "cloudwatch_memory_alarm_period" {
  type        = number
  default     = 300
  description = "Period in seconds for the memory alarm metric evaluation"
  nullable    = false

  validation {
    condition     = var.cloudwatch_memory_alarm_period >= 60
    error_message = "Alarm period must be at least 60 seconds."
  }
}

variable "cloudwatch_alarm_actions" {
  type        = list(string)
  default     = []
  description = "List of ARNs (e.g., SNS topics) to notify when an alarm transitions to ALARM state"
  nullable    = false
}

variable "cloudwatch_ok_actions" {
  type        = list(string)
  default     = []
  description = "List of ARNs (e.g., SNS topics) to notify when an alarm transitions to OK state"
  nullable    = false
}

variable "container_resource_requirements" {
  type = list(object({
    type  = string
    value = string
  }))
  default     = null
  description = "GPU or inference accelerator requirements (Fargate only)"
}

# ==============================================================================
# ECS SERVICE CONFIGURATION
# ==============================================================================

variable "desired_count" {
  type        = number
  default     = 1
  description = "Desired number of ECS tasks to run"
  nullable    = false

  validation {
    condition     = var.desired_count >= 0
    error_message = "Desired count must be 0 or greater."
  }
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  default     = 100
  description = "Minimum percentage of tasks that must remain healthy during deployment"
  nullable    = false

  validation {
    condition     = var.deployment_minimum_healthy_percent >= 0 && var.deployment_minimum_healthy_percent <= 100
    error_message = "Deployment minimum healthy percent must be between 0 and 100."
  }
}

variable "deployment_maximum_percent" {
  type        = number
  default     = 200
  description = "Maximum percentage of tasks allowed during deployment"
  nullable    = false

  validation {
    condition     = var.deployment_maximum_percent >= 100
    error_message = "Deployment maximum percent must be at least 100."
  }
}

variable "enable_execute_command" {
  type        = bool
  default     = false
  description = "Enable ECS Exec for interactive access to containers"
  nullable    = false
}

variable "enable_container_insights" {
  type        = bool
  default     = false
  description = "Enable CloudWatch Container Insights for the ECS cluster"
  nullable    = false
}

variable "assign_public_ip" {
  type        = bool
  default     = false
  description = "Assign public IP addresses to tasks (Fargate with awsvpc mode only)"
  nullable    = false
}

# ==============================================================================
# EC2 LAUNCH CONFIGURATION (EC2 Launch Type Only)
# ==============================================================================

variable "instance_types" {
  type        = list(string)
  default     = ["t3.small", "t3.medium", "t3a.small", "t3a.medium", "t4g.small"]
  description = "EC2 instance types for ECS container instances (EC2 launch type only)"
  nullable    = false
}

variable "ami_id" {
  type        = string
  default     = ""
  description = "AMI ID for ECS instances (defaults to latest ECS-optimized Amazon Linux 2023 AMI if empty)"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "Minimum number of EC2 instances in the Auto Scaling Group (EC2 launch type only)"
  nullable    = false

  validation {
    condition     = var.min_size >= 0
    error_message = "Minimum size must be 0 or greater."
  }
}

variable "max_size" {
  type        = number
  default     = 3
  description = "Maximum number of EC2 instances in the Auto Scaling Group (EC2 launch type only)"
  nullable    = false

  validation {
    condition     = var.max_size >= 1
    error_message = "Maximum size must be at least 1."
  }
}

variable "desired_capacity" {
  type        = number
  default     = 2
  description = "Desired number of EC2 instances in the Auto Scaling Group (EC2 launch type only)"
  nullable    = false

  validation {
    condition     = var.desired_capacity >= 0
    error_message = "Desired capacity must be 0 or greater."
  }
}

variable "root_volume_size" {
  type        = number
  default     = 30
  description = "Root EBS volume size in GB for EC2 instances (EC2 launch type only)"
  nullable    = false

  validation {
    condition     = var.root_volume_size >= 30
    error_message = "Root volume size must be at least 30 GB (ECS-optimized AMI requirement)."
  }
}

variable "root_volume_type" {
  type        = string
  default     = "gp3"
  description = "Root EBS volume type for EC2 instances (EC2 launch type only)"
  nullable    = false

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
    error_message = "Root volume type must be one of: gp2, gp3, io1, io2."
  }
}

variable "root_volume_encrypted" {
  type        = bool
  default     = true
  description = "Encrypt root EBS volume for EC2 instances (EC2 launch type only)"
  nullable    = false
}

variable "ebs_optimized" {
  type        = bool
  default     = true
  description = "Enable EBS optimization for EC2 instances (EC2 launch type only)"
  nullable    = false
}

variable "enable_monitoring" {
  type        = bool
  default     = true
  description = "Enable detailed CloudWatch monitoring for EC2 instances (EC2 launch type only)"
  nullable    = false
}

variable "enable_asg_metrics" {
  type        = bool
  default     = true
  description = "Enable Auto Scaling Group metrics collection (EC2 launch type only)"
  nullable    = false
}

variable "user_data_extra" {
  type        = string
  default     = ""
  description = "Additional user data script to append after the default ECS configuration (EC2 launch type only)"
}

variable "use_spot" {
  type        = bool
  default     = true
  description = "Use spot instances instead of on-demand for ECS EC2 instances"
  nullable    = false
}

# ==============================================================================
# EC2 CAPACITY PROVIDER CONFIGURATION (EC2 Launch Type Only)
# ==============================================================================

variable "protect_from_scale_in" {
  type        = bool
  default     = false
  description = "Enable scale-in protection for the capacity provider (EC2 launch type only)"
  nullable    = false
}

variable "target_capacity" {
  type        = number
  default     = 100
  description = "Target capacity percentage for the capacity provider (EC2 launch type only)"
  nullable    = false

  validation {
    condition     = var.target_capacity > 0 && var.target_capacity <= 100
    error_message = "Target capacity must be between 1 and 100."
  }
}

variable "minimum_scaling_step_size" {
  type        = number
  default     = 1
  description = "Minimum number of instances to add/remove during scaling (EC2 launch type only)"
  nullable    = false

  validation {
    condition     = var.minimum_scaling_step_size >= 1
    error_message = "Minimum scaling step size must be at least 1."
  }
}

variable "maximum_scaling_step_size" {
  type        = number
  default     = 3
  description = "Maximum number of instances to add/remove during scaling (EC2 launch type only)"
  nullable    = false

  validation {
    condition     = var.maximum_scaling_step_size >= 1
    error_message = "Maximum scaling step size must be at least 1."
  }
}

# ==============================================================================
# LOAD BALANCER CONFIGURATION
# ==============================================================================

variable "target_group_arn" {
  type        = string
  default     = ""
  description = "ARN of an existing target group to attach the service to (leave empty to create new target groups)"
}

variable "target_groups" {
  type = map(object({
    port                          = number
    protocol                      = string
    target_type                   = string
    deregistration_delay          = optional(number, 30)
    slow_start                    = optional(number, 0)
    load_balancing_algorithm_type = optional(string, "round_robin")
    stickiness = optional(object({
      enabled         = bool
      type            = string
      cookie_duration = optional(number, 86400)
      cookie_name     = optional(string, "")
    }), null)
    health_check = object({
      enabled             = optional(bool, true)
      healthy_threshold   = optional(number, 2)
      unhealthy_threshold = optional(number, 3)
      timeout             = optional(number, 5)
      interval            = optional(number, 30)
      path                = optional(string, "/")
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "HTTP")
      matcher             = optional(string, "200")
    })
  }))
  default     = {}
  description = "Map of target groups to create and attach to the service"
}

variable "alb_name" {
  type        = string
  default     = ""
  description = "Name of an existing Application Load Balancer to create listener rules for"
  nullable    = false
}

variable "listener_rules" {
  type = map(object({
    priority = number
    conditions = optional(list(object({
      path_pattern = optional(list(string), [])
      host_header  = optional(list(string), [])
      http_header = optional(object({
        name   = string
        values = list(string)
      }), null)
      query_string = optional(list(object({
        key   = optional(string, "")
        value = string
      })), [])
      source_ip = optional(list(string), [])
    })), [{ path_pattern = [] }])
  }))
  default     = {}
  description = "Map of ALB listener rules to create for routing traffic to this service"
  nullable    = false
}
