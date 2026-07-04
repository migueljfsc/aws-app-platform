environment  = "dev"
service_name = "app"
region       = "us-east-1"

certificates = {
  default = {
    domain_name               = "dev.my.domain.com"
    subject_alternative_names = ["*.dev.my.domain.com", "stg.my.domain.com", "*.stg.my.domain.com"]
    validation_method         = "DNS"
    wait_for_validation       = true
  }
}
