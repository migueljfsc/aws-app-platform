# ECS Task Role
resource "aws_iam_role" "this" {
  name = "${var.service_name}-${var.deploy_context}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.service_name}-${var.deploy_context}-ecs-task"
  }
}

# ECS Exec policy
resource "aws_iam_role_policy" "this" {
  name = "${var.service_name}-${var.deploy_context}-ecs-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "ssm:GetParameters",
          "kms:Decrypt"
        ]
        Resource = ["*"]
      }
    ]
  })

  lifecycle {
    enabled = var.enable_execute_command
  }
}
