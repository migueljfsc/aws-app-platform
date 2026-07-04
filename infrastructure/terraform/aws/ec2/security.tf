resource "aws_key_pair" "this" {
  key_name   = "${var.service_name}-${module.aws_registry.deploy_context}"
  public_key = "placeholder"

  lifecycle {
    enabled        = var.key_name == ""
    ignore_changes = [public_key]
  }
}

resource "aws_secretsmanager_secret" "this" {
  name = "${var.service_name}-${module.aws_registry.deploy_context}"
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = "placeholder"

  lifecycle {
    ignore_changes = [secret_string]
  }
}
