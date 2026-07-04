module "user_service" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  functions = {
    api = {
      handler  = "index.handler"
      runtime  = "python3.11"
      filename = "../dist/function.zip"

      timeout     = 30
      memory_size = 512

      environment_variables = {
        USER_POOL_ID = "XXXXX"
        TABLE_NAME   = "XXXXX"
      }

      # Inline policy for DynamoDB access
      inline_policies = {
        dynamodb = {
          policy_statements = [{
            effect = "Allow"
            actions = [
              "dynamodb:GetItem",
              "dynamodb:PutItem",
              "dynamodb:UpdateItem",
              "dynamodb:DeleteItem",
              "dynamodb:Query",
              "dynamodb:Scan"
            ]
            resources = ["XXXXX"]
          }]
        }
      }

      # API Gateway integration with Cognito authorizer
      api_gateway = {
        #api_id   = "XXXXX"
        api_name = "XXXXX"
        api_type = "HTTP"

        routes = {
          # Public endpoint - no auth
          health = {
            http_method        = "GET"
            path               = "/users/health"
            authorization_type = "NONE"
          }

          # Protected endpoints - require Cognito JWT
          list_users = {
            http_method        = "GET"
            path               = "/users"
            authorization_type = "JWT"
            authorizer_id      = "XXXXX"
          }

          get_user = {
            http_method        = "GET"
            path               = "/users/{id}"
            authorization_type = "JWT"
            authorizer_id      = "XXXXX"
          }

          create_user = {
            http_method        = "POST"
            path               = "/users"
            authorization_type = "JWT"
            authorizer_id      = "XXXXX"
          }

          update_user = {
            http_method        = "PUT"
            path               = "/users/{id}"
            authorization_type = "JWT"
            authorizer_id      = "XXXXX"
          }

          delete_user = {
            http_method        = "DELETE"
            path               = "/users/{id}"
            authorization_type = "JWT"
            authorizer_id      = "XXXXX"
          }
        }
      }
    }
  }
}
