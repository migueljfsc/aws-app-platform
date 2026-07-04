# Must be us-east-1 — CloudFront is a global service anchored there
resource "aws_cloudwatch_log_group" "cloudfront" {
  provider = aws.use1

  name              = "/aws/cloudfront/${var.service_name}-${module.aws_registry.deploy_context}"
  log_group_class   = "STANDARD"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_delivery_source" "cloudfront" {
  provider = aws.use1

  name         = "${var.service_name}-${module.aws_registry.deploy_context}-cf-source"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.this.arn
}

resource "aws_cloudwatch_log_delivery_destination" "cloudfront" {
  provider = aws.use1

  name          = "${var.service_name}-${module.aws_registry.deploy_context}-cf-dest"
  output_format = "json"

  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.cloudfront.arn
  }
}

resource "aws_cloudwatch_log_delivery" "cloudfront" {
  provider = aws.use1

  delivery_source_name     = aws_cloudwatch_log_delivery_source.cloudfront.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.cloudfront.arn

  record_fields = [
    "date",
    "time",
    "x-edge-location",
    "sc-bytes",
    "c-ip",
    "cs-method",
    "cs(Host)",
    "cs-uri-stem",
    "sc-status",
    "cs(Referer)",
    "cs(User-Agent)",
    "cs-uri-query",
    "cs(Cookie)",
    "x-edge-result-type",
    "x-edge-request-id",
    "x-host-header",
    "cs-protocol",
    "cs-bytes",
    "time-taken",
    "x-forwarded-for",
    "ssl-protocol",
    "ssl-cipher",
    "x-edge-response-result-type",
    "cs-protocol-version",
    "fle-status",
    "fle-encrypted-fields",
    "c-port",
    "time-to-first-byte",
    "x-edge-detailed-result-type",
    "sc-content-type",
    "sc-content-len",
    "sc-range-start",
    "sc-range-end",
  ]
}
