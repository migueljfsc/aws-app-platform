environment  = "dev"
service_name = "app-infra-tf-state"

bucket_name = "app-infra-tf-state"

versioning_enabled = true

allowed_iam_arns = [
  "arn:aws:iam::123456789012:role/github-actions-infra-plan",
  "arn:aws:iam::123456789012:role/github-actions-infra-apply",
]

allowed_iam_permissions = ["read", "write", "list", "delete"]
