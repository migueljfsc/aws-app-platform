locals {
  api_name = "${var.service_name}-${module.aws_registry.deploy_context}"

  # Default access log format (JSON)
  default_access_log_format = jsonencode({
    requestId          = "$context.requestId"
    ip                 = "$context.identity.sourceIp"
    caller             = "$context.identity.caller"
    user               = "$context.identity.user"
    requestTime        = "$context.requestTime"
    httpMethod         = "$context.httpMethod"
    resourcePath       = "$context.resourcePath"
    status             = "$context.status"
    protocol           = "$context.protocol"
    responseLength     = "$context.responseLength"
    integrationLatency = "$context.integrationLatency"
    responseLatency    = "$context.responseLatency"
    errorMessage       = "$context.error.message"
    errorType          = "$context.error.messageString"
  })

  certificate_arn = var.certificate_arn != "" ? var.certificate_arn : data.aws_acm_certificate.this.arn
}
