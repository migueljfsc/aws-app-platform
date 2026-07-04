locals {
  iam_user_name = var.iam_user_name != "" ? var.iam_user_name : "${local.bucket_name}-user"

  permission_actions = {
    read   = ["s3:GetObject", "s3:GetObjectVersion"]
    write  = ["s3:PutObject", "s3:PutObjectAcl"]
    delete = ["s3:DeleteObject", "s3:DeleteObjectVersion"]
    list   = ["s3:ListBucket", "s3:ListBucketVersions"]
  }

  cloudfront_policy = var.create_cloudfront_oai ? [{
    Sid    = "CloudFrontOAI"
    Effect = "Allow"
    Principal = {
      AWS = aws_cloudfront_origin_access_identity.this.iam_arn
    }
    Action   = ["s3:GetObject"]
    Resource = "${aws_s3_bucket.this.arn}/*"
  }] : []

  allowed_service_principals_policy = length(var.allowed_service_principals) > 0 ? [for idx, sp in var.allowed_service_principals : merge(
    {
      Sid    = "AllowServicePrincipal${idx}"
      Effect = "Allow"
      Principal = {
        Service = sp.identifier
      }
      Action   = sp.actions
      Resource = sp.include_bucket_arn ? [aws_s3_bucket.this.arn, "${aws_s3_bucket.this.arn}/*"] : ["${aws_s3_bucket.this.arn}/*"]
    },
    sp.source_arn != "" ? {
      Condition = {
        StringEquals = {
          "aws:SourceArn" = sp.source_arn
        }
      }
    } : {}
  )] : []

  allowed_iam_policy = length(var.allowed_iam_arns) > 0 ? [{
    Sid    = "AllowedIAMAccess"
    Effect = "Allow"
    Principal = {
      AWS = var.allowed_iam_arns
    }
    Action = concat(
      contains(var.allowed_iam_permissions, "list") ? local.permission_actions["list"] : [],
      flatten([
        for perm in var.allowed_iam_permissions :
        contains(["read", "write", "delete"], perm) ? local.permission_actions[perm] : []
      ])
    )
    Resource = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }] : []

  bucket_policy_statements = concat(
    local.cloudfront_policy,
    local.allowed_iam_policy,
    local.allowed_service_principals_policy
  )
}

# IAM User for bucket access
resource "aws_iam_user" "this" {
  name = local.iam_user_name

  lifecycle {
    enabled = var.create_iam_user
  }
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name

  lifecycle {
    enabled = var.create_iam_user
  }
}

resource "aws_iam_user_policy" "this" {
  name = "${local.iam_user_name}-policy"
  user = aws_iam_user.this.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      contains(var.iam_user_permissions, "list") ? [{
        Effect = "Allow"
        Action = local.permission_actions["list"]
        Resource = [
          aws_s3_bucket.this.arn
        ]
      }] : [],
      length(setintersection(var.iam_user_permissions, ["read", "write", "delete"])) > 0 ? [{
        Effect = "Allow"
        Action = flatten([
          for perm in var.iam_user_permissions :
          contains(["read", "write", "delete"], perm) ? local.permission_actions[perm] : []
        ])
        Resource = [
          "${aws_s3_bucket.this.arn}/*"
        ]
      }] : []
    )
  })

  lifecycle {
    enabled = var.create_iam_user
  }
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "this" {
  comment = var.cloudfront_oai_comment != "" ? var.cloudfront_oai_comment : "OAI for ${local.bucket_name}"

  lifecycle {
    enabled = var.create_cloudfront_oai
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.bucket_policy_statements
  })

  lifecycle {
    enabled = length(local.bucket_policy_statements) > 0
  }

  depends_on = [aws_s3_bucket_public_access_block.this]
}
