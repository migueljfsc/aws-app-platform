terraform {
  required_version = "~> 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = module.aws_registry.region

  default_tags {
    tags = module.aws_registry.tags
  }
}

provider "aws" {
  alias = "use1"

  region = "us-east-1"

  default_tags {
    tags = module.aws_registry.tags
  }
}
