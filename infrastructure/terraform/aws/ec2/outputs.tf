
output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = var.internal ? null : aws_instance.this.public_ip
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "instance_hostname" {
  value = var.route53_zone_name != "" ? aws_route53_record.this.fqdn : null
}
