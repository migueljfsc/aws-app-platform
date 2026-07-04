# Event Source Mappings
resource "aws_lambda_event_source_mapping" "this" {
  for_each = merge([
    for fn_key, fn in var.functions : {
      for source_key, source in fn.event_sources :
      "${fn_key}-${source_key}" => merge(source, {
        function_name = aws_lambda_function.this[fn_key].arn
      })
    }
  ]...)

  function_name     = each.value.function_name
  event_source_arn  = each.value.event_source_arn
  enabled           = each.value.enabled
  batch_size        = each.value.batch_size
  starting_position = each.value.starting_position != "" ? each.value.starting_position : null

  maximum_batching_window_in_seconds = each.value.maximum_batching_window_in_seconds > 0 ? each.value.maximum_batching_window_in_seconds : null
  maximum_retry_attempts             = each.value.maximum_retry_attempts >= 0 ? each.value.maximum_retry_attempts : null
  maximum_record_age_in_seconds      = each.value.maximum_record_age_in_seconds >= 0 ? each.value.maximum_record_age_in_seconds : null
  bisect_batch_on_function_error     = each.value.bisect_batch_on_function_error
  parallelization_factor             = each.value.parallelization_factor

  dynamic "destination_config" {
    for_each = each.value.on_failure_destination_arn != "" ? [1] : []
    content {
      on_failure {
        destination_arn = each.value.on_failure_destination_arn
      }
    }
  }

  dynamic "filter_criteria" {
    for_each = length(each.value.filter_criteria) > 0 ? [1] : []
    content {
      dynamic "filter" {
        for_each = each.value.filter_criteria
        content {
          pattern = filter.value.pattern
        }
      }
    }
  }
}
