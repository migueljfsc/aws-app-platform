module "tags" {
  source = "../"

  repository   = "github.com/app-io/infra-aws-registry"
  environment  = "dev"
  service_name = "myapp"
}
