resource "aws_ecs_capacity_provider" "this" {
  name = "${var.service_name}-${var.deploy_context}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.this.arn
    managed_termination_protection = var.protect_from_scale_in ? "ENABLED" : "DISABLED"

    managed_scaling {
      minimum_scaling_step_size = var.minimum_scaling_step_size
      maximum_scaling_step_size = var.maximum_scaling_step_size
      status                    = "ENABLED"
      target_capacity           = var.target_capacity
    }
  }

  tags = {
    Name = "${var.service_name}-${var.deploy_context}-capacity-provider"
  }

  lifecycle {
    enabled = local.is_ec2
  }
}

resource "aws_launch_template" "this" {
  name_prefix = "${var.service_name}-${var.deploy_context}-"
  image_id    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id

  vpc_security_group_ids = data.aws_security_groups.this.ids

  iam_instance_profile {
    arn = data.aws_iam_instance_profile.this.arn
  }

  key_name = var.key_name

  monitoring {
    enabled = var.enable_monitoring
  }

  ebs_optimized = var.ebs_optimized

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      encrypted             = var.root_volume_encrypted
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name    = aws_ecs_cluster.this.name
    user_data_extra = var.user_data_extra
  }))

  dynamic "tag_specifications" {
    for_each = toset(concat(["instance", "volume", "network-interface"], var.use_spot ? ["spot-instances-request"] : []))
    content {
      resource_type = tag_specifications.value
      tags = merge(
        var.ec2_template_tags,
        {
          Name = "${var.service_name}-${var.deploy_context}-ecs-${tag_specifications.value}"
        }
      )
    }
  }

  lifecycle {
    enabled               = local.is_ec2
    create_before_destroy = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.service_name}-${var.deploy_context}-asg"
  vpc_zone_identifier = data.aws_subnets.this.ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.this.id
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = var.instance_types

        content {
          instance_type = override.value
        }
      }
    }

    instances_distribution {
      spot_allocation_strategy                 = "capacity-optimized"
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
    }
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  enabled_metrics = var.enable_asg_metrics ? [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ] : []

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  target_group_arns = [for tg in aws_lb_target_group.this : tg.arn]

  dynamic "tag" {
    for_each = var.ec2_template_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    enabled               = local.is_ec2
    create_before_destroy = true
  }
}
