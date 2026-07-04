module "event_processors" {
  source = "../"

  deploy_context = "dev-euw3"
  service_name   = "myapp"

  functions = {
    # Process orders from SQS
    order_processor = {
      handler  = "orders.handler"
      runtime  = "python3.11"
      filename = "../dist/order-processor.zip"

      timeout     = 60
      memory_size = 1024

      # SQS event source
      event_sources = {
        orders_queue = {
          type                               = "sqs"
          event_source_arn                   = aws_sqs_queue.orders.arn
          batch_size                         = 10
          maximum_batching_window_in_seconds = 5

          # Advanced retry settings
          maximum_retry_attempts         = 3
          bisect_batch_on_function_error = true

          # Filter only specific order types
          filter_criteria = [{
            pattern = jsonencode({
              body = {
                orderType = ["premium", "enterprise"]
              }
            })
          }]
        }
      }

      # Permissions for SQS
      inline_policies = {
        sqs = {
          policy_statements = [{
            effect = "Allow"
            actions = [
              "sqs:ReceiveMessage",
              "sqs:DeleteMessage",
              "sqs:GetQueueAttributes"
            ]
            resources = [aws_sqs_queue.orders.arn]
          }]
        }
      }
    }

    # Process DynamoDB stream events
    stream_processor = {
      handler  = "stream.handler"
      runtime  = "python3.11"
      filename = "../dist/stream-processor.zip"

      timeout     = 30
      memory_size = 512

      # DynamoDB stream event source
      event_sources = {
        events_stream = {
          type              = "dynamodb"
          event_source_arn  = aws_dynamodb_table.events.stream_arn
          starting_position = "LATEST"
          batch_size        = 100

          parallelization_factor         = 10
          maximum_record_age_in_seconds  = 3600
          bisect_batch_on_function_error = true

          # Send failed records to DLQ
          on_failure_destination_arn = aws_sqs_queue.dlq.arn
        }
      }

      # Permissions for DynamoDB Streams
      inline_policies = {
        dynamodb = {
          policy_statements = [{
            effect = "Allow"
            actions = [
              "dynamodb:GetRecords",
              "dynamodb:GetShardIterator",
              "dynamodb:DescribeStream",
              "dynamodb:ListStreams"
            ]
            resources = [aws_dynamodb_table.events.stream_arn]
          }]
        }
      }
    }
  }
}
