resource "aws_ecs_cluster" "data_ingress_cluster" {
  name               = local.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.data_ingress_cluster.name]

  tags = merge(
    local.common_repo_tags,
    {
      Name = "data-ingress-cluster"
    }
  )

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  lifecycle {
    ignore_changes = [
      setting,
    ]
  }
}

resource "aws_cloudwatch_log_group" "data_ingress_cluster" {
  name              = local.name_data_ingress_log_group
  retention_in_days = 180
  tags = merge(
    local.common_repo_tags,
    {
      Name = "data_ingress_cluster_logs"
    }
  )
}

resource "aws_ecs_capacity_provider" "data_ingress_cluster" {
  name = local.autoscaling_group_name
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.data_ingress_server.arn
    managed_termination_protection = "DISABLED"
    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 5
    }
  }
  lifecycle {
    ignore_changes = all
  }


  tags = merge(
    local.common_repo_tags,
    {
      Name = "data_ingress_cluster_logs"
    }
  )
}

resource "aws_autoscaling_group" "data_ingress_server" {
  name                      = local.autoscaling_group_name
  min_size                  = local.data_ingress_server_asg_min[local.environment]
  desired_capacity          = local.data_ingress_server_asg_desired[local.environment]
  max_size                  = local.data_ingress_server_asg_max[local.environment]
  protect_from_scale_in     = false
  health_check_grace_period = 600
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity.*.id
  launch_template {
    id      = aws_launch_template.data_ingress_server.id
    version = aws_launch_template.data_ingress_server.latest_version
  }
  dynamic "tag" {
    for_each = local.data_ingress_server_tags_asg
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "data_ingress_server" {
  name          = local.launch_template_name
  image_id      = var.ecs_hardened_ami_id
  instance_type = var.data_ingress_server_ec2_instance_type[local.environment]
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.data_ingress_server.id]
    subnet_id                   = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity.0.id
  }
  user_data = base64encode(templatefile("files/data_ingress_cluster_userdata.tpl", {
    cluster_name  = local.cluster_name
    instance_role = aws_iam_instance_profile.data_ingress_server.name
    region        = data.aws_region.current.name
    folder        = "/mnt/config"
    mnt_bucket    = data.terraform_remote_state.common.outputs.config_bucket.id
    name          = local.launch_template_name
  }))
  instance_initiated_shutdown_behavior = "terminate"
  iam_instance_profile {
    arn = aws_iam_instance_profile.data_ingress_server.arn
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    local.common_repo_tags,
    {
      Name = local.cluster_name
    }
  )
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.common_repo_tags,
      {
        Application  = "data_ingress_server"
        Name         = "data_ingress_server"
        Persistence  = "Ignore"
        AutoShutdown = "False"
        SSMEnabled   = local.data_ingress_server_ssmenabled[local.environment]
      }
    )
  }
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_repo_tags,
      {
        Application = "data_ingress_server"
        Name        = "data_ingress_server"
      }
    )
  }
}
