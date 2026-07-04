# Lambda Functions
resource "aws_lambda_function" "this" {
  for_each = var.functions

  function_name = "${var.service_name}-${var.deploy_context}-${each.key}"
  description   = each.value.description != "" ? each.value.description : "Lambda function for ${var.service_name} ${each.key}"

  role    = each.value.create_role ? aws_iam_role.this[each.key].arn : each.value.role_arn
  handler = each.value.package_type == "Zip" ? each.value.handler : null
  runtime = each.value.package_type == "Zip" ? each.value.runtime : null

  # Code source
  filename          = each.value.filename != "" ? each.value.filename : null
  s3_bucket         = each.value.s3_bucket != "" ? each.value.s3_bucket : null
  s3_key            = each.value.s3_key != "" ? each.value.s3_key : null
  s3_object_version = each.value.s3_object_version != "" ? each.value.s3_object_version : null
  image_uri         = each.value.image_uri != "" ? each.value.image_uri : null

  package_type  = each.value.package_type
  architectures = each.value.architectures

  # Function settings
  timeout     = each.value.timeout
  memory_size = each.value.memory_size

  reserved_concurrent_executions = each.value.reserved_concurrent_executions

  # Environment
  dynamic "environment" {
    for_each = length(each.value.environment_variables) > 0 ? [1] : []
    content {
      variables = each.value.environment_variables
    }
  }

  # VPC
  dynamic "vpc_config" {
    for_each = each.value.vpc_config != null ? [each.value.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  # Dead Letter Queue
  dynamic "dead_letter_config" {
    for_each = each.value.dead_letter_config != null ? [each.value.dead_letter_config] : []
    content {
      target_arn = dead_letter_config.value.target_arn
    }
  }

  # Layers
  layers = each.value.layers

  # Ephemeral storage
  ephemeral_storage {
    size = each.value.ephemeral_storage_size
  }

  # Tracing
  tracing_config {
    mode = each.value.tracing_mode
  }

  # File system
  dynamic "file_system_config" {
    for_each = each.value.file_system_config != null ? [each.value.file_system_config] : []
    content {
      arn              = file_system_config.value.arn
      local_mount_path = file_system_config.value.local_mount_path
    }
  }

  # Image config
  dynamic "image_config" {
    for_each = each.value.image_config != null ? [each.value.image_config] : []
    content {
      command           = image_config.value.command
      entry_point       = image_config.value.entry_point
      working_directory = image_config.value.working_directory
    }
  }

  publish = each.value.provisioned_concurrent_executions > 0 || length(each.value.aliases) > 0

  tags = {
    Name = "${var.service_name}-${var.deploy_context}-${each.key}"
  }

  depends_on = [
    aws_iam_role_policy_attachment.basic,
    aws_iam_role_policy_attachment.vpc,
    aws_cloudwatch_log_group.this
  ]
}

# Provisioned Concurrency
resource "aws_lambda_provisioned_concurrency_config" "this" {
  for_each = {
    for k, v in var.functions : k => v if v.provisioned_concurrent_executions > 0
  }

  function_name                     = aws_lambda_function.this[each.key].function_name
  provisioned_concurrent_executions = each.value.provisioned_concurrent_executions
  qualifier                         = aws_lambda_function.this[each.key].version
}
