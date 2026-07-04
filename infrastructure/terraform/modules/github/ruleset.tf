resource "github_repository_ruleset" "this" {
  name        = var.repository_branch
  repository  = var.repository_name != "" ? var.repository_name : var.service_name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/${var.repository_branch}"]
      exclude = []
    }
  }

  dynamic "bypass_actors" {
    for_each = var.bypass_actors
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  rules {
    deletion                = true
    required_linear_history = true
    non_fast_forward        = true

    pull_request {
      required_approving_review_count   = 1
      require_code_owner_review         = true
      dismiss_stale_reviews_on_push     = true
      required_review_thread_resolution = false
    }

    required_status_checks {
      dynamic "required_check" {
        for_each = var.required_checks
        content {
          context = required_check.value.context

          # only set if provided
          integration_id = try(required_check.value.integration_id, null)
        }
      }

      strict_required_status_checks_policy = false
    }
  }
}
