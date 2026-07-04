module "api_services" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  functions = {
    # Public API - no auth
    public = {
      handler  = "public.handler"
      runtime  = "nodejs20.x"
      filename = "../dist/public.zip"

      api_gateway = {
        #api_id           = "XXXXX"
        api_name         = "XXXXX"
        api_type         = "REST"
        root_resource_id = "XXXXX"

        routes = {
          health = {
            http_method        = "GET"
            path               = "/health"
            authorization_type = "NONE"
          }

          docs = {
            http_method        = "GET"
            path               = "/docs"
            authorization_type = "NONE"
          }
        }
      }
    }

    # User API - Cognito auth
    users = {
      handler  = "users.handler"
      runtime  = "nodejs20.x"
      filename = "../dist/users.zip"

      environment_variables = {
        TABLE_NAME = "XXXXX"
      }

      api_gateway = {
        #api_id           = "XXXXX"
        api_name         = "XXXXX"
        api_type         = "REST"
        root_resource_id = "XXXXX"

        routes = {
          get_profile = {
            http_method        = "GET"
            path               = "/profile"
            authorization_type = "COGNITO_USER_POOLS"
            authorizer_id      = "XXXXX"
          }

          update_profile = {
            http_method        = "PUT"
            path               = "/profile"
            authorization_type = "COGNITO_USER_POOLS"
            authorizer_id      = "XXXXX"
          }
        }
      }
    }

    # Admin API - Custom Lambda authorizer
    admin = {
      handler  = "admin.handler"
      runtime  = "nodejs20.x"
      filename = "../dist/admin.zip"

      environment_variables = {
        ADMIN_TABLE = "XXXXX"
      }

      api_gateway = {
        #api_id           = "XXXXX"
        api_name         = "XXXXX"
        api_type         = "REST"
        root_resource_id = "XXXXX"

        routes = {
          list_users = {
            http_method        = "GET"
            path               = "/admin/users"
            authorization_type = "CUSTOM"
            authorizer_id      = "XXXXX"
          }

          delete_user = {
            http_method        = "DELETE"
            path               = "/admin/users/{id}"
            authorization_type = "CUSTOM"
            authorizer_id      = "XXXXX"
          }
        }
      }
    }

    # Partner API - API Key required
    partner = {
      handler  = "partner.handler"
      runtime  = "nodejs20.x"
      filename = "../dist/partner.zip"

      api_gateway = {
        #api_id           = "XXXXX"
        api_name         = "XXXXX"
        api_type         = "REST"
        root_resource_id = "XXXXX"

        routes = {
          get_data = {
            http_method      = "GET"
            path             = "/partner/data"
            api_key_required = true
          }

          post_webhook = {
            http_method      = "POST"
            path             = "/partner/webhook"
            api_key_required = true
          }
        }
      }
    }
  }
}
