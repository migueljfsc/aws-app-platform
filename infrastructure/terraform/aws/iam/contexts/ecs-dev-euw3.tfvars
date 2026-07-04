environment  = "dev"
service_name = "ecs"

# ==========================================
# Service Roles
# ==========================================
roles = {
  # ECS
  ecs-task-execution = {
    description = "ECS task execution role"
    assume_role_policy = {
      principals = [{ type = "Service", identifiers = ["ecs-tasks.amazonaws.com"] }]
    }
  }
  # EC2
  ec2-app-server = {
    description = "EC2 application servers"
    assume_role_policy = {
      principals = [{ type = "Service", identifiers = ["ec2.amazonaws.com"] }]
    }
  }
}

# ==========================================
# Role Policies (Managed attachments)
# ==========================================
role_policy_attachments = {
  ecs-execution = {
    role_key   = "ecs-task-execution"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  }

  ec2-ssm = {
    role_key   = "ec2-app-server"
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  ec2-ecs-agent = {
    role_key   = "ec2-app-server"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  }
}

# ==========================================
# Role Policies
# ==========================================
role_policies = {
  ecs-execution-secrets = {
    role_key = "ecs-task-execution"
    policy_statements = [
      {
        sid    = "AllowSecretAccess"
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        resources  = ["*"]
        conditions = []
      }
    ]
  }
}


# ==========================================
# Instance Profiles
# ==========================================
instance_profiles = {
  ec2-app-server = {
    role_key = "ec2-app-server"
  }
}
