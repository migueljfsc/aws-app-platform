locals {
  # Auto-inject Environment tag from var.environment, merge with any explicit cost_tags
  all_cost_tags = {
    for key, budget in var.budgets : key => merge(
      # { Environment = [var.environment] },
      budget.cost_tags
    )
  }

  budget_cost_filters = {
    for key, budget in var.budgets : key => merge(
      budget.cost_filters,
      {
        TagKeyValue = flatten([
          for tag_key, tag_values in local.all_cost_tags[key] : [
            for tag_value in tag_values : format("user:%s$%s", tag_key, tag_value)
          ]
        ])
      }
    )
  }
}

resource "aws_budgets_budget" "this" {
  for_each = var.budgets

  name         = "${var.service_name}-${module.aws_registry.deploy_context}-${each.key}"
  budget_type  = each.value.budget_type
  limit_amount = each.value.limit_amount
  limit_unit   = each.value.limit_unit
  time_unit    = each.value.time_unit

  time_period_start = each.value.time_period_start
  time_period_end   = each.value.time_period_end

  dynamic "cost_filter" {
    for_each = local.budget_cost_filters[each.key]

    content {
      name   = cost_filter.key
      values = cost_filter.value
    }
  }

  dynamic "cost_types" {
    for_each = each.value.cost_types != null ? [each.value.cost_types] : []

    content {
      include_credit             = cost_types.value.include_credit
      include_discount           = cost_types.value.include_discount
      include_other_subscription = cost_types.value.include_other_subscription
      include_recurring          = cost_types.value.include_recurring
      include_refund             = cost_types.value.include_refund
      include_subscription       = cost_types.value.include_subscription
      include_support            = cost_types.value.include_support
      include_tax                = cost_types.value.include_tax
      include_upfront            = cost_types.value.include_upfront
      use_amortized              = cost_types.value.use_amortized
      use_blended                = cost_types.value.use_blended
    }
  }

  dynamic "notification" {
    for_each = each.value.notifications

    content {
      comparison_operator       = notification.value.comparison_operator
      threshold                 = notification.value.threshold
      threshold_type            = notification.value.threshold_type
      notification_type         = notification.value.notification_type
      subscriber_sns_topic_arns = [module.sns.topic_arn]
    }
  }
}
