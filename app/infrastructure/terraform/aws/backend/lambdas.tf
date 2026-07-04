module "lambda" {
  source = "../../../../../infrastructure/terraform/modules/lambda"

  deploy_context = module.aws_registry.deploy_context
  service_name   = var.service_name

  functions = {
    api = {
      handler      = "index.handler"
      package_type = "Image"
      image_uri    = "${local.ecr_image}:${var.container_image_tag}"

      timeout     = 30
      memory_size = 512

      # API Gateway integration with Cognito authorizer
      api_gateway = {
        api_name = "${var.api_gateway_name}-${module.aws_registry.deploy_context}"
        api_type = var.api_gateway_type

        routes = {
          proxy = {
            http_method        = "ANY"
            path               = var.route_path
            authorization_type = var.api_gateway_authorization_type
            authorizer_id      = var.api_gateway_authorizer_id
          }
        }
      }
    }
  }
}
