module "ecr_global" {
  source = "../"

  service_name = "myapp"

  enable_cross_account_replication = true

  replication_configuration = {
    rules = [
      {
        destinations = [
          {
            region      = "eu-west-2"
            registry_id = "123456789012"
          },
          {
            region      = "eu-west-3"
            registry_id = "123456789012"
          }
        ]
      }
    ]
  }
}
