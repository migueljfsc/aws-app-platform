###################### MODULE VARIABLES ######################

# ==============================================================================
# GENERAL VARIABLES
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
# INSTANCE CONFIGURATION
# ==============================================================================

variable "ami" {
  type        = string
  description = "The AMI ID to use for the instance. Default will fetch latest Amazon Linux 2"
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "The type of EC2 instance to launch"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "The key name for the instance"
  default     = ""
}

variable "root_volume_size" {
  type        = number
  description = "Size of the root EBS volume in GB"
  default     = 30
}

variable "user_data" {
  type        = string
  description = "User data script to execute on instance boot"
  default     = ""
}

# ==============================================================================
# NETWORK & SECURITY
# ==============================================================================

variable "vpc_name" {
  type        = string
  description = "(Optional) VPC name, defaults to context VPC"
  default     = ""
}

variable "internal" {
  type        = bool
  description = "Determines whether the instance should be internal (no public IP)"
  default     = true
}

variable "security_group_rules" {
  type = map(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string, "")
  }))
  description = "Map of security group rules to apply to the instance."
  default = {
    "ssh_in" = {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow SSH from anywhere"
    },
    "all_out" = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  }
}

variable "external_sg_inbound_rules" {
  type = map(object({
    security_group_name = string
    from_port           = number
    to_port             = number
    protocol            = string
    description         = optional(string, "")
  }))
  description = "Map of rules to add to external security groups, allowing inbound traffic from this instance's SG."
  default     = {}
}


# ==============================================================================
# IAM CONFIGURATION
# ==============================================================================

variable "create_iam_role" {
  type        = bool
  description = "Determines whether an IAM role should be created for the instance"
  default     = true
}

variable "iam_instance_profile" {
  type        = string
  description = "Provide an existing IAM instance profile name if `create_iam_role` is false"
  default     = ""
}

variable "iam_managed_policy_arns" {
  type        = list(string)
  description = "Additional managed policy ARNs to attach to the IAM role (SSM is always included)"
  default     = []
}

variable "iam_inline_policies" {
  type        = map(string)
  description = "Map of inline policy name to JSON policy document to attach to the IAM role"
  default     = {}
}

# ==============================================================================
# DNS CONFIGURATION
# ==============================================================================

variable "route53_zone_name" {
  type        = string
  description = "The Route53 Zone to associate the instance's record with"
  default     = ""
}
