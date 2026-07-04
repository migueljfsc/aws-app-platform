# IAM role for SSM access
resource "aws_iam_role" "this" {
  name = "${var.service_name}-${module.aws_registry.deploy_context}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}-role"
  }

  lifecycle {
    enabled = var.create_iam_role
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

  lifecycle {
    enabled = var.create_iam_role
  }
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.service_name}-${module.aws_registry.deploy_context}-profile"
  role = aws_iam_role.this.name

  lifecycle {
    enabled = var.create_iam_role
  }
}

resource "aws_iam_role_policy_attachment" "extra" {
  for_each = var.create_iam_role ? toset(var.iam_managed_policy_arns) : toset([])

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.create_iam_role ? var.iam_inline_policies : {}

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}
