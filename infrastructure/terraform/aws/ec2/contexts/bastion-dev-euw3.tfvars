environment  = "dev"
service_name = "bastion"

internal = false

route53_zone_name = "dev.my.domain.com"

# Offices & VPN
security_group_rules = {
  "ssh_internal" = {
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.10/32"]
    description = "Allow SSH from app Offices and VPN"
  }
  "all_outbound" = {
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

external_sg_inbound_rules = {
  "allow_bastion_to_rds" = {
    security_group_name = "app-dev-euw3-rds"
    from_port           = 5432
    to_port             = 5432
    protocol            = "tcp"
    description         = "Allow PostgreSQL inbound from Bastion"
  }
  "allow_bastion_to_elasticache" = {
    security_group_name = "app-dev-euw3-elasticache"
    from_port           = 6379
    to_port             = 6379
    protocol            = "tcp"
    description         = "Allow Redis inbound from Bastion"
  }
  "allow_bastion_to_ecs_ec2" = {
    security_group_name = "app-dev-euw3-ecs-ec2"
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
    description         = "Allow SSH inbound from Bastion"
  }
  "allow_bastion_to_ecs_fargate" = {
    security_group_name = "app-dev-euw3-ecs-fargate"
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
    description         = "Allow SSH inbound from Bastion"
  }
}

iam_inline_policies = {
  "ssm-session-initiation" = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ssm:StartSession",
            "ssm:TerminateSession",
            "ssm:ResumeSession",
            "ssm:DescribeSessions",
            "ssm:DescribeInstanceInformation",
            "ecs:ExecuteCommand"
          ],
          "Resource": "*"
        }
      ]
    }
  EOT
}

user_data = <<-EOF
  #!/bin/bash
  set -e

  yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
EOF
