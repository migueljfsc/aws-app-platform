environment  = "dev"
service_name = "budget"

budgets = {
  # ====================================
  # Total monthly spend ceiling
  # ====================================
  monthly-total = {
    limit_amount = "250"
    time_unit    = "MONTHLY"

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 50
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # Compute guard
  # ====================================
  compute = {
    limit_amount = "15"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["Amazon Elastic Container Service", "EC2-Instances", "EC2 - Other"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # Networking guard
  # ====================================
  networking = {
    limit_amount = "90"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["Amazon Virtual Private Cloud"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # ALB guard — load balancer usage
  # ====================================
  alb = {
    limit_amount = "25"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["Amazon Elastic Load Balancing"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # CloudFront guard
  # ====================================
  cloudfront = {
    limit_amount = "5"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["Amazon CloudFront"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # WAF guard — web ACL request costs
  # ====================================
  waf = {
    limit_amount = "15"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["AWS WAF"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 95
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # CloudWatch guard — logs ingestion and storage
  # ====================================
  cloudwatch = {
    limit_amount = "5"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["Amazon CloudWatch"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # S3 guard — storage and request costs
  # ====================================
  s3 = {
    limit_amount = "5"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["Amazon Simple Storage Service"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }
  # ====================================
  # ECR guard — container image storage
  # ====================================
  ecr = {
    limit_amount = "5"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["Amazon EC2 Container Registry (ECR)"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # Secrets Manager guard — secret storage and API calls
  # ====================================
  secrets = {
    limit_amount = "5"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["AWS Secrets Manager"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # Route 53 guard — hosted zone and query costs
  # ====================================
  route53 = {
    limit_amount = "5"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["Amazon Route 53"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # AWS Config guard — configuration item and rule evaluation costs
  # ====================================
  config = {
    limit_amount = "10"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["AWS Config"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # SNS guard — topics and messages
  # ====================================
  sns = {
    limit_amount = "5"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["Amazon Simple Notification Service"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # RDS guard — database costs
  # ====================================
  rds = {
    limit_amount = "50"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["Amazon Relational Database Service"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # Lambda guard — function invocation and compute costs
  # ====================================
  lambda = {
    limit_amount = "5"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["AWS Lambda"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # API Gateway guard — API call and data transfer costs
  # ====================================
  api_gateway = {
    limit_amount = "5"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["Amazon API Gateway"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }

  # ====================================
  # ElastiCache guard — node and data transfer costs
  # ====================================
  elasticache = {
    limit_amount = "15"
    time_unit    = "MONTHLY"

    cost_filters = {
      Service = ["Amazon ElastiCache"]
    }

    notifications = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      }
    ]
  }
}
