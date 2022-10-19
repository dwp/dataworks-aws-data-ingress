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
      setting, tags
    ]
  }
}

resource "aws_cloudwatch_log_group" "data_ingress_cluster" {
  name              = local.name_data_ingress_log_group
  retention_in_days = 180
  lifecycle {ignore_changes = [tags]}
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
    auto_scaling_group_arn = aws_autoscaling_group.data_ingress_server.arn
    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
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

resource "aws_network_interface" "di_ni_receiver" {
  lifecycle {
    ignore_changes = [tags]
  }
  private_ips = [cidrhost(data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[0].cidr_block, 14)]
  security_groups = [aws_security_group.data_ingress_server.id]
  subnet_id       = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity.0.id
  tags            = merge(local.common_repo_tags, { Name = "di-ni-receiver" })
}

resource "aws_sns_topic" "email_trend_micro_team" {
  name = "email_trend_micro_team"
  tags = {
    Name = "email_trend_micro_team_topic"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}


resource "aws_autoscaling_group" "data_ingress_server" {
  name = local.autoscaling_group_name
  min_size              = local.asg_instance_count.off
  max_size              = local.asg_instance_count.off
  desired_capacity      = local.asg_instance_count.off
  protect_from_scale_in = false
  default_cooldown      = 30
  force_delete          = true
  vpc_zone_identifier   = contains(["development","qa"], local.environment) ? [data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[0].id, data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[1].id] : [data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[0].id]
  # set mono subnet in higher envs to ensure the instance is started in the required az when capacity is equal to 1
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
  lifecycle {
    create_before_destroy = true
    ignore_changes = [tags]
  }
}

resource "aws_autoscaling_schedule" "on" {
  scheduled_action_name  = "on"
  desired_capacity       = local.asg_instance_count.desired[local.environment]
  max_size               = local.asg_instance_count.max[local.environment]
  min_size               = local.asg_instance_count.min[local.environment]
  recurrence             = "00 23 1 * *"
  start_time             = timeadd(timestamp(), "6m")
  time_zone              = local.time_zone
  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name
  lifecycle {
    ignore_changes = [start_time, end_time, recurrence]
  }
}

resource "aws_autoscaling_schedule" "off" {
  scheduled_action_name  = "off"
  desired_capacity       = local.asg_instance_count.off
  max_size               = local.asg_instance_count.off
  min_size               = local.asg_instance_count.off
  recurrence             = "00 23 4 * *"
  time_zone              = local.time_zone
  start_time             = timeadd(timestamp(), "8m")
  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name
  lifecycle {
    ignore_changes = [start_time, end_time, recurrence]
  }
}

resource "aws_autoscaling_schedule" "test_on" {
  count                  = contains(["development", "qa"], local.environment) ? 1 : 0
  scheduled_action_name  = "test_scaling_on"
  desired_capacity       = local.asg_instance_count.test_desired
  max_size               = local.asg_instance_count.test_max
  recurrence             = format("%s %s", formatdate("mm hh DD MM", timeadd(timestamp(), "65m")), " *")
  start_time             = timeadd(timestamp(), "3m")
  end_time               = timeadd(timestamp(), "80m")
  time_zone              = local.time_zone
  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name
  lifecycle {
    ignore_changes = [start_time, end_time, recurrence]
  }
}

resource "aws_autoscaling_schedule" "test_off" {
  count                  = contains(["development", "qa"], local.environment) ? 1 : 0
  scheduled_action_name  = "test_scaling_off"
  desired_capacity       = local.asg_instance_count.off
  max_size               = local.asg_instance_count.off
  recurrence             = format("%s %s", formatdate("mm hh DD MM", timeadd(timestamp(), "78m")), " *")
  time_zone              = local.time_zone
  start_time             = timeadd(timestamp(), "4m")
  end_time               = timeadd(timestamp(), "80m")
  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name
  lifecycle {
    ignore_changes = [start_time, end_time, recurrence]
  }
}

resource "aws_launch_template" "data_ingress_server" {
  name                    = local.launch_template_name
  image_id                = var.ecs_hardened_ami_id
  instance_type           = var.data_ingress_server_ec2_instance_type[local.environment]
  disable_api_termination = false
  lifecycle {
    create_before_destroy = true
    ignore_changes = [latest_version, tags]
  }
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
    proxy_host    = data.terraform_remote_state.aws_sdx.outputs.internet_proxy.host
    proxy_port    = local.proxy_port
    secret_name   = local.secret_trendmicro
  }))
  instance_initiated_shutdown_behavior = "terminate"
  iam_instance_profile {
    arn = aws_iam_instance_profile.data_ingress_server.arn
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

data "aws_secretsmanager_secret" "trendmicro" {
  name = local.secret_trendmicro
}
