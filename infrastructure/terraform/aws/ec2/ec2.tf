resource "aws_instance" "this" {
  ami                    = var.ami != "" ? var.ami : data.aws_ami.this.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.this.ids[0]
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name               = var.key_name != "" ? var.key_name : aws_key_pair.this.key_name
  iam_instance_profile   = var.create_iam_role ? aws_iam_instance_profile.this.name : (var.iam_instance_profile != "" ? var.iam_instance_profile : null)

  associate_public_ip_address = !var.internal

  user_data = var.user_data != "" ? var.user_data : null

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.service_name}-${module.aws_registry.deploy_context}"
  }
}
