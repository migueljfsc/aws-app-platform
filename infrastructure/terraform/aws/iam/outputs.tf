# Users
output "user_names" {
  value       = { for k, v in aws_iam_user.this : k => v.name }
  description = "Map of user names"
}

output "user_arns" {
  value       = { for k, v in aws_iam_user.this : k => v.arn }
  description = "Map of user ARNs"
}

output "user_access_keys" {
  value       = { for k, v in aws_iam_access_key.this : k => { id = v.id, secret = v.secret } }
  description = "Map of user access keys"
  sensitive   = true
}

output "user_login_profile_passwords" {
  value       = { for k, v in aws_iam_user_login_profile.this : k => v.password }
  description = "Map of user login passwords"
  sensitive   = true
}

# Groups
output "group_names" {
  value       = { for k, v in aws_iam_group.this : k => v.name }
  description = "Map of group names"
}

output "group_arns" {
  value       = { for k, v in aws_iam_group.this : k => v.arn }
  description = "Map of group ARNs"
}

# Roles
output "role_names" {
  value       = { for k, v in aws_iam_role.this : k => v.name }
  description = "Map of role names"
}

output "role_arns" {
  value       = { for k, v in aws_iam_role.this : k => v.arn }
  description = "Map of role ARNs"
}

# Policies
output "policy_names" {
  value       = { for k, v in aws_iam_policy.this : k => v.name }
  description = "Map of policy names"
}

output "policy_arns" {
  value       = { for k, v in aws_iam_policy.this : k => v.arn }
  description = "Map of policy ARNs"
}

# Instance Profiles
output "instance_profile_names" {
  value       = { for k, v in aws_iam_instance_profile.this : k => v.name }
  description = "Map of instance profile names"
}

output "instance_profile_arns" {
  value       = { for k, v in aws_iam_instance_profile.this : k => v.arn }
  description = "Map of instance profile ARNs"
}

# OIDC Providers
output "oidc_provider_arns" {
  value       = { for k, v in aws_iam_openid_connect_provider.this : k => v.arn }
  description = "Map of OIDC provider ARNs"
}

# SAML Providers
output "saml_provider_arns" {
  value       = { for k, v in aws_iam_saml_provider.this : k => v.arn }
  description = "Map of SAML provider ARNs"
}
