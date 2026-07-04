locals {
  aws_region_short_map = {
    # North America
    "us-east-1"    = "use1"
    "us-east-2"    = "use2"
    "us-west-1"    = "usw1"
    "us-west-2"    = "usw2"
    "ca-central-1" = "can1"
    "ca-west-1"    = "can2"
    "mx-central-1" = "mxc1"

    # Africa
    "af-south-1" = "afs1"

    # Asia Pacific
    "ap-east-1"      = "ape1"
    "ap-east-2"      = "ape2"
    "ap-northeast-1" = "apn1"
    "ap-northeast-2" = "apn2"
    "ap-northeast-3" = "apn3"
    "ap-south-1"     = "aps3"
    "ap-south-2"     = "aps5"
    "ap-southeast-1" = "aps1"
    "ap-southeast-2" = "aps2"
    "ap-southeast-3" = "aps4"
    "ap-southeast-4" = "aps6"
    "ap-southeast-5" = "aps7"
    "ap-southeast-6" = "aps8"
    "ap-southeast-7" = "aps9"

    # Europe
    "eu-central-1" = "euc1"
    "eu-central-2" = "euc2"
    "eu-west-1"    = "euw1"
    "eu-west-2"    = "euw2"
    "eu-west-3"    = "euw3"
    "eu-north-1"   = "eun1"
    "eu-south-1"   = "eus1"
    "eu-south-2"   = "eus2"

    # Middle East
    "il-central-1" = "ilc1"
    "me-central-1" = "mec1"
    "me-south-1"   = "mes1"

    # South America
    "sa-east-1" = "sae1"
  }

  region_short = lookup(local.aws_region_short_map, var.region, "unknown")

  deploy_context = var.deploy_context != "" ? var.deploy_context : "${var.environment}-${local.region_short}"

  account_names = {
    "123456789012" = "App Dev"
    "210987654321" = "App Stg"
  }

  account_name = lookup(local.account_names, data.aws_caller_identity.current.account_id, "UnknownAccount")

  # Collect all the possible tags
  provided_tags = merge(tomap({
    "ManagedBy"      = "Terraform"
    "DeployedBy"     = var.deployed_by != "" ? var.deployed_by : data.aws_caller_identity.current.arn
    "Repository"     = var.repository
    "AwsAccountId"   = data.aws_caller_identity.current.account_id
    "AwsAccountName" = local.account_name
    "Service"        = var.service_name
    "DeployContext"  = local.deploy_context
    "Environment"    = var.environment
    "Region"         = var.region
    "Team"           = var.team
  }))

  non_empty_tags = {
    for tag_key, tag_value in local.provided_tags :
    tag_key => tag_value if tag_value != ""
  }

  # Final tags
  tags = merge(
    local.non_empty_tags,
    var.additional_tags
  )
}
