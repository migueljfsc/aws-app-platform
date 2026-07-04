# SNS Topic
module "sns_events" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "lambda"

  lambda_subscriptions = {
    processor = {
      endpoint = "arn:aws:lambda:eu-west-3:123456789012:function:my-function"
    }
  }
}
